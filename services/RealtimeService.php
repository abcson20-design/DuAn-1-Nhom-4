<?php

declare(strict_types=1);

require_once __DIR__ . '/../models/BaseModel.php';

/**
 * RealtimeService - Quản lý sự kiện và thông báo Real-time cho toàn bộ hệ thống NEXVORA
 * Cơ chế: Event-driven + Long-polling / Smart Polling siêu nhẹ
 * Mọi thay đổi ở Khách hàng (Đặt hàng, Hủy đơn, Đánh giá, Giỏ hàng...)
 * hoặc Admin (Cập nhật đơn, Đổi trạng thái, Thêm/Sửa/Xóa SP, Danh mục, Mã giảm giá...)
 * đều được ghi nhận vào hệ thống và phát tới Client / Admin ngay lập tức.
 */
class RealtimeService
{
    private static ?PDO $db = null;

    private static function getDb(): PDO
    {
        if (self::$db === null) {
            self::$db = Database::getConnection();
            self::ensureTable();
        }
        return self::$db;
    }

    /**
     * Tự động tạo bảng realtime_events nếu chưa có
     */
    public static function ensureTable(): void
    {
        try {
            $db = Database::getConnection();
            $sql = "CREATE TABLE IF NOT EXISTS `realtime_events` (
                `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                `event_type` VARCHAR(64) NOT NULL,
                `scope` ENUM('all', 'client', 'admin') NOT NULL DEFAULT 'all',
                `entity_type` VARCHAR(64) NOT NULL,
                `entity_id` VARCHAR(64) NULL,
                `action` VARCHAR(64) NOT NULL,
                `title` VARCHAR(255) NOT NULL,
                `message` TEXT NULL,
                `payload` LONGTEXT NULL,
                `user_id` INT UNSIGNED NULL,
                `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_created` (`created_at`),
                INDEX `idx_scope_type` (`scope`, `event_type`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;";
            $db->exec($sql);
        } catch (Throwable $e) {
            error_log('[RealtimeService ensureTable Error] ' . $e->getMessage());
        }
    }

    /**
     * Phát một sự kiện Real-time mới
     */
    public static function publish(
        string $eventType,
        string $scope = 'all',
        string $entityType = '',
        $entityId = null,
        string $action = '',
        string $title = '',
        string $message = '',
        array $payload = [],
        ?int $userId = null
    ): void {
        try {
            $db = self::getDb();
            $stmt = $db->prepare("INSERT INTO `realtime_events` 
                (`event_type`, `scope`, `entity_type`, `entity_id`, `action`, `title`, `message`, `payload`, `user_id`, `created_at`) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())");
            
            $stmt->execute([
                $eventType,
                $scope,
                $entityType,
                $entityId !== null ? (string)$entityId : null,
                $action,
                $title,
                $message,
                !empty($payload) ? json_encode($payload, JSON_UNESCAPED_UNICODE) : null,
                $userId
            ]);

            // Dọn dẹp các sự kiện cũ quá 2 giờ để bảng luôn nhẹ và tốc độ truy vấn < 1ms
            if (mt_rand(1, 100) === 1) {
                $db->exec("DELETE FROM `realtime_events` WHERE `created_at` < DATE_SUB(NOW(), INTERVAL 2 HOUR)");
            }
        } catch (Throwable $e) {
            error_log('[RealtimeService publish Error] ' . $e->getMessage());
        }
    }

    /**
     * Lấy các sự kiện mới nhất kể từ ID cuối cùng
     */
    public static function getEventsSince(int $lastEventId, string $scope = 'client', int $limit = 30): array
    {
        try {
            $db = self::getDb();
            
            if ($scope === 'admin') {
                $stmt = $db->prepare("SELECT * FROM `realtime_events` 
                    WHERE `id` > ? AND (`scope` = 'admin' OR `scope` = 'all') 
                    ORDER BY `id` ASC LIMIT ?");
            } else {
                $stmt = $db->prepare("SELECT * FROM `realtime_events` 
                    WHERE `id` > ? AND (`scope` = 'client' OR `scope` = 'all') 
                    ORDER BY `id` ASC LIMIT ?");
            }
            
            $stmt->bindValue(1, $lastEventId, PDO::PARAM_INT);
            $stmt->bindValue(2, $limit, PDO::PARAM_INT);
            $stmt->execute();
            
            $events = $stmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($events as &$evt) {
                if (!empty($evt['payload'])) {
                    $evt['payload'] = json_decode($evt['payload'], true);
                } else {
                    $evt['payload'] = [];
                }
            }
            return $events;
        } catch (Throwable $e) {
            error_log('[RealtimeService getEventsSince Error] ' . $e->getMessage());
            return [];
        }
    }

    /**
     * Lấy ID sự kiện lớn nhất hiện tại
     */
    public static function getLatestEventId(): int
    {
        try {
            $db = self::getDb();
            $stmt = $db->query("SELECT MAX(`id`) FROM `realtime_events`");
            return (int)$stmt->fetchColumn() ?: 0;
        } catch (Throwable $e) {
            return 0;
        }
    }
}
