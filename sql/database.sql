-- ==============================================================
-- DỰ ÁN 1: HỆ THỐNG WEBSITE BÁN ĐIỆN THOẠI & PHỤ KIỆN (NEXVORA STORE)
-- BẢN CƠ SỞ DỮ LIỆU HOÀN CHỈNH TẤT-CẢ-TRONG-MỘT (ALL-IN-ONE DATABASE)
-- CƠ SỞ DỮ LIỆU: DuAn1_db (hoặc duan1_db)
-- BẢNG MÃ: UTF8MB4 (Hỗ trợ tiếng Việt đầy đủ 100%)
-- ==============================================================

CREATE DATABASE IF NOT EXISTS `DuAn1_db` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `DuAn1_db`;

-- Tắt kiểm tra khóa ngoại để xóa và tạo mới an toàn
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ==============================================================
-- BƯỚC 1: XÓA CÁC BẢNG CŨ ĐỂ TẠO MỚI SẠCH SẼ 100%
-- ==============================================================
DROP TABLE IF EXISTS `coupon_usages`;
DROP TABLE IF EXISTS `guest_reservations`;
DROP TABLE IF EXISTS `user_carts`;
DROP TABLE IF EXISTS `wishlists`;
DROP TABLE IF EXISTS `coupons`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `warranties`;
DROP TABLE IF EXISTS `product_reviews`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `contacts`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `product_attributes`;
DROP TABLE IF EXISTS `product_galleries`;
DROP TABLE IF EXISTS `product_colors`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `brands`;
DROP TABLE IF EXISTS `users`;

-- ==============================================================
-- BƯỚC 2: TẠO CẤU TRÚC CÁC BẢNG CHUẨN HÓA
-- ==============================================================

-- 1. BẢNG: `categories` (Danh mục sản phẩm)
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT 'Tên danh mục',
  `slug` varchar(255) NOT NULL COMMENT 'Đường dẫn tĩnh chuẩn SEO',
  `type` enum('phone','accessory') DEFAULT 'accessory' COMMENT 'Phân loại: phone hoặc accessory',
  `icon` varchar(50) DEFAULT 'fa-solid fa-mobile-screen' COMMENT 'Icon FontAwesome',
  `description` text DEFAULT NULL COMMENT 'Mô tả danh mục',
  `created_at` datetime DEFAULT current_timestamp(),
  `deleted_at` datetime DEFAULT NULL COMMENT 'Thời gian xóa mềm (NULL: hoạt động, có giá trị: trong thùng rác)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng danh mục sản phẩm';

-- 2. BẢNG: `brands` (Thương hiệu / Hãng sản xuất)
CREATE TABLE `brands` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Tên thương hiệu',
  `slug` varchar(100) NOT NULL COMMENT 'Slug thương hiệu',
  `is_phone_brand` tinyint(1) DEFAULT 0 COMMENT '1: Hãng điện thoại, 0: Hãng phụ kiện',
  `logo` varchar(255) DEFAULT NULL COMMENT 'Ảnh logo thương hiệu',
  `deleted_at` datetime DEFAULT NULL COMMENT 'Thời gian xóa mềm (NULL: hoạt động, có giá trị: trong thùng rác)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng thương hiệu sản phẩm';

-- 3. BẢNG: `users` (Tài khoản người dùng & Quản trị viên)
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fullname` varchar(150) NOT NULL COMMENT 'Họ và tên',
  `email` varchar(150) NOT NULL COMMENT 'Email đăng nhập',
  `phone` varchar(20) DEFAULT NULL COMMENT 'Số điện thoại',
  `password` varchar(255) NOT NULL COMMENT 'Mật khẩu đã mã hóa bcrypt',
  `role` enum('admin','customer') DEFAULT 'customer' COMMENT 'Vai trò tài khoản',
  `address` text DEFAULT NULL COMMENT 'Địa chỉ giao hàng',
  `status` enum('active','blocked') DEFAULT 'active' COMMENT 'Trạng thái hoạt động',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng người dùng và quản trị';

-- 4. BẢNG: `products` (Sản phẩm điện thoại & Phụ kiện - HỖ TRỢ XÓA MỀM DELETED_AT)
CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL COMMENT 'ID danh mục',
  `brand_id` int(11) DEFAULT NULL COMMENT 'ID thương hiệu',
  `name` varchar(255) NOT NULL COMMENT 'Tên sản phẩm',
  `slug` varchar(255) NOT NULL COMMENT 'Đường dẫn tĩnh chuẩn SEO',
  `price` decimal(12,0) NOT NULL COMMENT 'Giá bán hiện tại (VNĐ)',
  `old_price` decimal(12,0) DEFAULT NULL COMMENT 'Giá niêm yết cũ (VNĐ)',
  `image` varchar(500) NOT NULL COMMENT 'Ảnh đại diện chính',
  `gallery` text DEFAULT NULL COMMENT 'Thư viện ảnh cấu tạo JSON',
  `video` varchar(500) DEFAULT NULL COMMENT 'Đường dẫn Video YouTube trải nghiệm',
  `colors` text DEFAULT NULL COMMENT 'Cấu hình 4 màu sắc & tồn kho từng màu JSON',
  `media_type` enum('slideshow','video') DEFAULT 'slideshow' COMMENT 'Loại media ưu tiên: slideshow hoặc video',
  `quantity` int(11) DEFAULT 50 COMMENT 'Tổng số lượng tồn kho',
  `description` longtext DEFAULT NULL COMMENT 'Mô tả chi tiết sản phẩm',
  `specs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Bảng thông số kỹ thuật chuẩn JSON',
  `compatible_device` varchar(255) DEFAULT 'Tất cả dòng máy' COMMENT 'Dòng máy tương thích',
  `is_featured` tinyint(1) DEFAULT 0 COMMENT 'Sản phẩm nổi bật (1: Có, 0: Không)',
  `is_hot` tinyint(1) DEFAULT 0 COMMENT 'Sản phẩm Hot bán chạy',
  `rating` decimal(2,1) DEFAULT 5.0 COMMENT 'Đánh giá trung bình (1.0 - 5.0)',
  `views` int(11) DEFAULT 0 COMMENT 'Lượt xem sản phẩm',
  `deleted_at` datetime DEFAULT NULL COMMENT 'Thời gian xóa mềm (Thùng rác). NULL: đang bán bình thường',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `fk_prod_cat` (`category_id`),
  KEY `fk_prod_brand` (`brand_id`),
  KEY `idx_deleted_at` (`deleted_at`),
  CONSTRAINT `fk_prod_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_prod_cat` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng sản phẩm điện thoại và phụ kiện (có xóa mềm)';

-- 5. BẢNG: `product_attributes` (Thuộc tính & Thông số kỹ thuật sản phẩm - ATTRIBUTES)
CREATE TABLE `product_attributes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL COMMENT 'Khóa ngoại trỏ đến products(id)',
  `name` varchar(100) NOT NULL COMMENT 'Tên thuộc tính (Màn hình, CPU, RAM, Bluetooth, Chống ồn ANC...)',
  `value` text NOT NULL COMMENT 'Giá trị thuộc tính',
  `group_name` varchar(50) DEFAULT 'Thông số kỹ thuật' COMMENT 'Nhóm thuộc tính: Màn hình, Hiệu năng, Âm thanh, Kết nối...',
  `sort_order` int(11) DEFAULT 0 COMMENT 'Thứ tự ưu tiên hiển thị',
  PRIMARY KEY (`id`),
  KEY `fk_attr_prod` (`product_id`),
  CONSTRAINT `fk_attr_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng thuộc tính thông số sản phẩm (Attributes)';

-- 6. BẢNG: `product_galleries` (Album ảnh chi tiết & Thư viện ảnh cấu tạo sản phẩm - ALBUMS / GALLERIES)
CREATE TABLE `product_galleries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL COMMENT 'Khóa ngoại trỏ đến products(id)',
  `image_url` varchar(500) NOT NULL COMMENT 'Đường dẫn ảnh trong album',
  `title` varchar(255) DEFAULT NULL COMMENT 'Tiêu đề góc chụp / Bộ phận cấu tạo',
  `tag` varchar(50) DEFAULT 'Ngoại quan' COMMENT 'Tag phân loại: Ngoại hình, Màn hình, Camera AI, Âm thanh...',
  `description` text DEFAULT NULL COMMENT 'Mô tả chi tiết ảnh / Linh kiện',
  `sort_order` int(11) DEFAULT 0 COMMENT 'Thứ tự hiển thị ảnh trong album',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_gallery_prod` (`product_id`),
  CONSTRAINT `fk_gallery_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng album ảnh chi tiết sản phẩm (Albums / Galleries)';

-- 7. BẢNG: `product_colors` (Biến thể màu sắc & Số lượng tồn kho theo màu)
CREATE TABLE `product_colors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL COMMENT 'Khóa ngoại trỏ đến products(id)',
  `color_name` varchar(100) NOT NULL COMMENT 'Tên màu sắc (VD: Titan Sa Mạc, Đen Cổ Điển...)',
  `color_image` varchar(500) DEFAULT NULL COMMENT 'Ảnh chụp đại diện riêng của màu này',
  `quantity` int(11) NOT NULL DEFAULT 50 COMMENT 'Số lượng hàng tồn kho của màu này',
  PRIMARY KEY (`id`),
  KEY `fk_color_prod` (`product_id`),
  CONSTRAINT `fk_color_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng biến thể màu sắc và tồn kho theo màu';

-- 8. BẢNG: `product_reviews` (Đánh giá & Bình luận sản phẩm)
CREATE TABLE `product_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL COMMENT 'ID sản phẩm được đánh giá',
  `user_id` int(11) DEFAULT NULL COMMENT 'ID tài khoản đánh giá (nếu có)',
  `author_name` varchar(150) NOT NULL COMMENT 'Họ tên người đánh giá',
  `author_email` varchar(150) DEFAULT NULL COMMENT 'Email người đánh giá',
  `author_phone` varchar(20) DEFAULT NULL COMMENT 'SĐT người đánh giá',
  `rating` tinyint(4) NOT NULL DEFAULT 5 COMMENT 'Số sao đánh giá (1-5 sao)',
  `content` text NOT NULL COMMENT 'Nội dung nhận xét đánh giá',
  `is_purchased` tinyint(1) DEFAULT 1 COMMENT '1: Đã mua hàng tại shop, 0: Chưa mua',
  `status` enum('approved','pending','hidden') DEFAULT 'approved' COMMENT 'Trạng thái kiểm duyệt',
  `likes` int(11) DEFAULT 0 COMMENT 'Lượt thích đánh giá',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_prod_status` (`product_id`,`status`),
  CONSTRAINT `fk_rev_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng đánh giá sản phẩm';

-- 9. BẢNG: `orders` (Đơn hàng mua sắm)
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_code` varchar(50) NOT NULL COMMENT 'Mã đơn hàng duy nhất',
  `user_id` int(11) DEFAULT NULL COMMENT 'ID tài khoản đặt hàng (nếu có)',
  `customer_name` varchar(150) NOT NULL COMMENT 'Tên khách hàng nhận hàng',
  `customer_phone` varchar(20) NOT NULL COMMENT 'SĐT khách hàng',
  `customer_email` varchar(150) DEFAULT NULL COMMENT 'Email khách hàng',
  `customer_address` text NOT NULL COMMENT 'Địa chỉ nhận hàng chi tiết',
  `notes` text DEFAULT NULL COMMENT 'Ghi chú đơn hàng từ khách',
  `total_amount` decimal(12,0) NOT NULL COMMENT 'Tổng tiền hàng',
  `discount_amount` decimal(12,0) DEFAULT 0 COMMENT 'Số tiền giảm giá voucher',
  `coupon_code` varchar(50) DEFAULT NULL COMMENT 'Mã voucher áp dụng cho đơn',
  `shipping_fee` decimal(12,0) DEFAULT 0 COMMENT 'Phí vận chuyển',
  `final_amount` decimal(12,0) NOT NULL COMMENT 'Số tiền thanh toán cuối cùng',
  `payment_method` enum('cod','vietqr','bank_transfer','sepay') NOT NULL DEFAULT 'sepay' COMMENT 'Phương thức thanh toán',
  `payment_status` enum('pending','paid','failed','refunded') DEFAULT 'pending' COMMENT 'Trạng thái thanh toán',
  `order_status` enum('pending','confirmed','shipping','completed','return_requested','returned','cancelled') DEFAULT 'pending' COMMENT 'Tiến trình đơn hàng (return_requested: khách yêu cầu trả hàng chờ duyệt, returned: đã trả hàng)',
  `cancel_reason` text DEFAULT NULL COMMENT 'Lý do khách hủy đơn',
  `refund_info` text DEFAULT NULL COMMENT 'Thông tin STK hoàn tiền của khách',
  `is_hidden_by_user` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Khách hàng ẩn đơn khỏi lịch sử cá nhân (1: Đã ẩn, 0: Bình thường)',
  `bank_transaction_id` varchar(100) DEFAULT NULL COMMENT 'Mã giao dịch ngân hàng / SePay',
  `completed_at` datetime DEFAULT NULL COMMENT 'Thời điểm giao hàng thành công (tính hạn đổi trả)',
  `shipped_at` datetime DEFAULT NULL COMMENT 'Thời điểm bắt đầu giao hàng',
  `is_stock_restored` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Đã hoàn kho',
  `is_coupon_released` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Đã hoàn mã giảm giá',
  `deleted_at` datetime DEFAULT NULL COMMENT 'Thời gian xóa mềm (Thùng rác)',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_code` (`order_code`),
  KEY `fk_order_user` (`user_id`),
  CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng đơn hàng mua sắm';

-- 10. BẢNG: `order_items` (Chi tiết các mặt hàng trong đơn)
CREATE TABLE `order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL COMMENT 'Khóa ngoại tham chiếu orders',
  `product_id` int(11) NOT NULL COMMENT 'Khóa ngoại tham chiếu products',
  `product_name` varchar(255) NOT NULL COMMENT 'Tên sản phẩm tại thời điểm mua',
  `product_image` varchar(500) DEFAULT NULL COMMENT 'Ảnh sản phẩm',
  `price` decimal(12,0) NOT NULL COMMENT 'Đơn giá mua',
  `quantity` int(11) NOT NULL COMMENT 'Số lượng mua',
  `total` decimal(12,0) NOT NULL COMMENT 'Thành tiền (giá x số lượng)',
  PRIMARY KEY (`id`),
  KEY `fk_order_items_order` (`order_id`),
  KEY `idx_item_product` (`product_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng chi tiết mặt hàng trong đơn';

-- 11. BẢNG: `payments` (Lịch sử giao dịch thanh toán trực tuyến SePay)
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL COMMENT 'ID đơn hàng tham chiếu orders',
  `order_code` varchar(50) NOT NULL COMMENT 'Mã đơn hàng (ví dụ: TS261112A1B2C)',
  `gateway` varchar(30) NOT NULL DEFAULT 'sepay' COMMENT 'Cổng thanh toán: sepay',
  `txn_ref` varchar(64) NOT NULL COMMENT 'Mã hoá đơn SePay (order_invoice_number)',
  `amount` decimal(12,0) NOT NULL COMMENT 'Số tiền thanh toán (VNĐ)',
  `status` enum('pending','success','failed') NOT NULL DEFAULT 'pending' COMMENT 'Trạng thái giao dịch',
  `transaction_no` varchar(100) DEFAULT NULL COMMENT 'Mã giao dịch ngân hàng trả về',
  `bank_code` varchar(50) DEFAULT NULL COMMENT 'Hình thức (BANK_TRANSFER, NAPAS...)',
  `response_code` varchar(50) DEFAULT NULL COMMENT 'Mã phản hồi từ SePay (ORDER_PAID)',
  `raw_data` longtext DEFAULT NULL COMMENT 'Toàn bộ dữ liệu JSON Webhook SePay gửi sang',
  `paid_at` datetime DEFAULT NULL COMMENT 'Thời gian thanh toán thành công',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_txn_ref` (`txn_ref`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_code` (`order_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử giao dịch thanh toán SePay';

-- 12. BẢNG: `warranties` (Bảo hành điện tử theo Mã IMEI / Số điện thoại)
CREATE TABLE `warranties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) DEFAULT NULL COMMENT 'Khóa ngoại tham chiếu orders',
  `product_id` int(11) NOT NULL COMMENT 'Khóa ngoại tham chiếu products',
  `imei_serial` varchar(100) NOT NULL COMMENT 'Mã IMEI hoặc Serial Number máy',
  `customer_phone` varchar(20) NOT NULL COMMENT 'SĐT kích hoạt bảo hành',
  `customer_name` varchar(150) NOT NULL COMMENT 'Tên khách hàng sở hữu',
  `warranty_months` int(11) DEFAULT 12 COMMENT 'Thời gian bảo hành (tháng)',
  `start_date` date NOT NULL COMMENT 'Ngày bắt đầu bảo hành',
  `end_date` date NOT NULL COMMENT 'Ngày hết hạn bảo hành',
  `status` enum('valid','expired','servicing') DEFAULT 'valid' COMMENT 'Trạng thái bảo hành',
  `notes` text DEFAULT NULL COMMENT 'Ghi chú kỹ thuật',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `imei_serial` (`imei_serial`),
  KEY `fk_warranty_order` (`order_id`),
  KEY `fk_warranty_prod` (`product_id`),
  CONSTRAINT `fk_warranty_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_warranty_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng bảo hành điện tử';

-- 13. BẢNG: `contacts` (Hộp thư liên hệ & Góp ý khách hàng)
CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL COMMENT 'ID tài khoản liên hệ',
  `fullname` varchar(150) NOT NULL COMMENT 'Họ tên người gửi',
  `email` varchar(150) NOT NULL COMMENT 'Email người gửi',
  `phone` varchar(20) DEFAULT NULL COMMENT 'Số điện thoại',
  `subject` varchar(255) NOT NULL COMMENT 'Tiêu đề liên hệ',
  `message` text NOT NULL COMMENT 'Nội dung tin nhắn',
  `status` enum('new','read','replied') DEFAULT 'new' COMMENT 'Trạng thái xử lý',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_contact_user` (`user_id`),
  CONSTRAINT `fk_contact_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng hộp thư liên hệ';

-- 14. BẢNG: `coupons` (Mã khuyến mại & Voucher giảm giá trực tiếp)
CREATE TABLE `coupons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL COMMENT 'Mã voucher (UPPERCASE)',
  `title` varchar(255) NOT NULL COMMENT 'Tên ưu đãi hiển thị',
  `discount_type` enum('fixed','percent') DEFAULT 'fixed' COMMENT 'fixed: giảm tiền mặt, percent: giảm phần trăm',
  `apply_scope` enum('all','category','product') NOT NULL DEFAULT 'all' COMMENT 'Phạm vi áp dụng: all: tất cả, category: 1 danh mục, product: 1 sản phẩm',
  `category_id` int(11) DEFAULT NULL COMMENT 'ID danh mục áp dụng (nếu apply_scope = category)',
  `product_id` int(11) DEFAULT NULL COMMENT 'ID sản phẩm áp dụng (nếu apply_scope = product)',
  `discount_value` decimal(12,0) NOT NULL COMMENT 'Mức giảm (VNĐ hoặc %)',
  `max_discount` decimal(12,0) DEFAULT NULL COMMENT 'Mức giảm tối đa cho phần trăm (VNĐ)',
  `min_order_amount` decimal(12,0) DEFAULT 0 COMMENT 'Giá trị đơn tối thiểu để áp dụng',
  `quantity` int(11) DEFAULT 100 COMMENT 'Số lượt sử dụng còn lại',
  `used_count` int(11) DEFAULT 0 COMMENT 'Số lượt đã sử dụng',
  `start_date` datetime DEFAULT current_timestamp() COMMENT 'Thời điểm bắt đầu áp dụng',
  `end_date` datetime DEFAULT NULL COMMENT 'Thời điểm hết hạn',
  `status` enum('active','inactive') DEFAULT 'active' COMMENT 'Trạng thái hoạt động',
  `deleted_at` datetime DEFAULT NULL COMMENT 'Xóa mềm / Thùng rác',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng mã khuyến mại & voucher giảm giá';

-- 15. BẢNG: `wishlists` (Danh sách sản phẩm yêu thích)
CREATE TABLE IF NOT EXISTS `wishlists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'Khóa ngoại tham chiếu users(id)',
  `product_id` int(11) NOT NULL COMMENT 'Khóa ngoại tham chiếu products(id)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wishlists_user_product_unique` (`user_id`, `product_id`),
  KEY `fk_wishlist_product` (`product_id`),
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wishlist_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng danh sách yêu thích Wishlist';

-- 16. BẢNG: `user_carts` (Giỏ hàng bền vững lưu theo tài khoản - Persistent Cart)
CREATE TABLE IF NOT EXISTS `user_carts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'Khóa ngoại tham chiếu users(id)',
  `product_id` int(11) NOT NULL COMMENT 'Khóa ngoại tham chiếu products(id)',
  `color` varchar(100) NOT NULL DEFAULT '' COMMENT 'Tùy chọn màu sắc sản phẩm',
  `quantity` int(11) NOT NULL DEFAULT 1 COMMENT 'Số lượng sản phẩm trong giỏ',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_product_color_unique` (`user_id`, `product_id`, `color`),
  KEY `fk_user_carts_product` (`product_id`),
  CONSTRAINT `fk_user_carts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_carts_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng giỏ hàng bền vững theo người dùng';

-- 17. BẢNG: `guest_reservations` (Đặt giữ chỗ nhanh dành cho khách chưa đăng nhập & quét IP chống ghim hàng)
CREATE TABLE IF NOT EXISTS `guest_reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL COMMENT 'ID sản phẩm giữ chỗ',
  `product_name` varchar(255) NOT NULL COMMENT 'Tên sản phẩm tại thời điểm giữ chỗ',
  `color` varchar(100) DEFAULT '' COMMENT 'Tùy chọn màu sắc',
  `quantity` int(11) DEFAULT 1 COMMENT 'Số lượng đặt giữ chỗ',
  `price` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Đơn giá sản phẩm',
  `customer_name` varchar(150) NOT NULL COMMENT 'Họ tên khách hàng',
  `customer_phone` varchar(20) NOT NULL COMMENT 'Số điện thoại liên hệ nhận hàng',
  `customer_address` text NOT NULL COMMENT 'Địa chỉ giao hàng',
  `notes` text DEFAULT NULL COMMENT 'Ghi chú của khách hàng',
  `ip_address` varchar(45) NOT NULL COMMENT 'Địa chỉ IP để quét chống ghim hàng ảo',
  `status` enum('pending','contacted','completed','cancelled') DEFAULT 'pending' COMMENT 'Trạng thái xử lý CSKH',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_guest_reservations_ip` (`ip_address`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng đặt giữ chỗ nhanh cho khách vãng lai';

-- 18. BẢNG: `coupon_usages` (Sổ ghi tên khách hàng sử dụng mã giảm giá - Mỗi người 1 lần, chống race-condition)
CREATE TABLE IF NOT EXISTS `coupon_usages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `coupon_id` int(11) NOT NULL COMMENT 'Khóa ngoại tham chiếu coupons(id)',
  `user_id` int(11) NOT NULL COMMENT 'Khóa ngoại tham chiếu users(id)',
  `order_id` int(11) DEFAULT NULL COMMENT 'Khóa ngoại tham chiếu orders(id)',
  `used_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm áp dụng mã',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_coupon_user` (`coupon_id`, `user_id`),
  KEY `fk_coupon_usages_coupon` (`coupon_id`),
  KEY `fk_coupon_usages_user` (`user_id`),
  CONSTRAINT `fk_coupon_usages_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_coupon_usages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sổ ghi tên khách hàng sử dụng mã giảm giá (Mỗi người 1 lần)';


-- ==============================================================
-- BƯỚC 3: DỮ LIỆU CẤU HÌNH GỐC HỆ THỐNG
-- (6 DANH MỤC, 10 THƯƠNG HIỆU & 1 TÀI KHOẢN ADMIN)
-- ==============================================================

-- 1. Danh mục sản phẩm gốc (Phân định rõ phone vs accessory)
INSERT INTO `categories` (`id`, `name`, `slug`, `type`, `icon`, `description`, `created_at`) VALUES
(1, 'Điện thoại thông minh', 'dien-thoai', 'phone', 'fa-solid fa-mobile-screen', 'Smartphone chính hãng các dòng Flagship và tầm trung', NOW()),
(2, 'Tai nghe Bluetooth', 'tai-nghe-bluetooth', 'accessory', 'fa-solid fa-headphones-simple', 'Tai nghe True Wireless (TWS), Headphone chống ồn ANC', NOW()),
(3, 'Tai nghe có dây', 'tai-nghe-co-day', 'accessory', 'fa-solid fa-headphones', 'Tai nghe cổng Type-C, Lightning, 3.5mm Hi-Res', NOW()),
(4, 'Củ sạc & Cáp sạc nhanh', 'cu-sac-cap-sac', 'accessory', 'fa-solid fa-bolt', 'Củ sạc công nghệ GaN siêu nhanh, cáp bọc dù bền bỉ', NOW()),
(5, 'Ốp lưng & Kính cường lực', 'op-lung-cuong-luc', 'accessory', 'fa-solid fa-shield-halved', 'Phụ kiện bảo vệ máy chuẩn quân đội, chống sốc, kính 9H', NOW()),
(6, 'Pin dự phòng', 'pin-du-phong', 'accessory', 'fa-solid fa-battery-three-quarters', 'Pin sạc dự phòng sạc nhanh, MagSafe không dây', NOW());

-- 2. Thương hiệu gốc hệ thống (10 thương hiệu lớn)
INSERT INTO `brands` (`id`, `name`, `slug`, `is_phone_brand`, `logo`) VALUES
(1, 'Apple', 'apple', 1, NULL),
(2, 'Samsung', 'samsung', 1, NULL),
(3, 'Xiaomi', 'xiaomi', 1, NULL),
(4, 'OPPO', 'oppo', 1, NULL),
(5, 'Sony', 'sony', 0, NULL),
(6, 'Anker', 'anker', 0, NULL),
(7, 'Baseus', 'baseus', 0, NULL),
(8, 'Soundpeats', 'soundpeats', 0, NULL),
(9, 'Ugreen', 'ugreen', 0, NULL),
(10, 'Hoco', 'hoco', 0, NULL);

-- 3. TÀI KHOẢN ADMIN ĐỂ ĐĂNG NHẬP QUẢN TRỊ
-- Email: duan1@gmail.com
-- Mật khẩu: 123456@
-- 3. TÀI KHOẢN NGƯỜI DÙNG KIỂM THỬ (ADMIN & KHÁCH HÀNG DEMO)
-- Mật khẩu chung: 123456@
INSERT INTO `users` (`id`, `fullname`, `email`, `phone`, `password`, `role`, `address`, `status`, `created_at`) VALUES
(1, 'Quản trị viên Admin', 'duan1@gmail.com', '0988888888', '$2y$10$30DnRIKFzl5XU2uL0tCNWu/YQpTscmUOuvebawf/3iDe7nHADtY7S', 'admin', 'Hà Nội', 'active', NOW()),
(2, 'Son Abc', 'abcson20@gmail.com', '0362225438', '$2y$10$30DnRIKFzl5XU2uL0tCNWu/YQpTscmUOuvebawf/3iDe7nHADtY7S', 'customer', 'Vân Cát - Cẩm Vân - Thanh Hóa', 'active', NOW());

-- Mã khuyến mại & Voucher ưu đãi mặc định
INSERT INTO `coupons` (`id`, `code`, `title`, `discount_type`, `apply_scope`, `category_id`, `product_id`, `discount_value`, `max_discount`, `min_order_amount`, `quantity`, `used_count`, `start_date`, `end_date`, `status`) VALUES
(1, 'NEXVORA50', 'Giảm ngay 50.000đ cho mọi đơn hàng từ 200k', 'fixed', 'all', NULL, NULL, 50000, NULL, 200000, 100, 0, NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 'active'),
(2, 'FLAGSHIP200', 'Ưu đãi siêu phẩm - Giảm 200.000đ điện thoại cao cấp', 'fixed', 'category', 1, NULL, 200000, NULL, 10000000, 50, 0, NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 'active'),
(3, 'PHUKIEN15', 'Giảm 15% tổng đơn phụ kiện & tai nghe (tối đa 150k)', 'percent', 'category', 4, NULL, 15, 150000, 300000, 80, 0, NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 'active'),
(4, 'FREESHIP', 'Miễn phí vận chuyển hỏa tốc toàn quốc (trừ 30.000đ)', 'fixed', 'all', NULL, NULL, 30000, NULL, 100000, 200, 0, NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 'active');

-- Bật lại kiểm tra khóa ngoại sau khi hoàn tất

-- =============================================================
-- DỮ LIỆU MẪU SẢN PHẨM THEO TỪNG DANH MỤC (MỖI LOẠI 3 SẢN PHẨM = 18 SP)
-- =============================================================

-- -------------------------------------------------------------
-- Dữ liệu mẫu bảng `products` (18 bản ghi)
-- -------------------------------------------------------------
INSERT INTO `products` (`id`, `category_id`, `brand_id`, `name`, `slug`, `price`, `old_price`, `image`, `gallery`, `video`, `colors`, `media_type`, `quantity`, `description`, `specs`, `compatible_device`, `is_featured`, `is_hot`, `rating`, `views`, `deleted_at`, `created_at`) VALUES
(1, 1, 1, 'iPhone 15 128GB Chính Hãng VN/A', 'iphone-15-128gb', 18490000, 19990000, 'https://placehold.co/800x800/111827/ffffff/png?text=iPhone+15+128GB+Ch%C3%ADnh+H%C3%A3ng+VN%2FA', '[{\"tag\": \"Thiết kế\", \"title\": \"Thiết kế hiện đại, cầm nắm thoải mái\", \"desc\": \"Ngoại hình tinh tế, hoàn thiện chắc chắn, phù hợp sử dụng hằng ngày.\", \"icon\": \"fa-solid fa-mobile-screen-button\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=iPhone+15+128GB+Ch%C3%ADnh+H%C3%A3ng+VN%2FA+-+Thi%E1%BA%BFt+k%E1%BA%BF\"}, {\"tag\": \"Camera\", \"title\": \"Chụp ảnh sắc nét, quay video mượt\", \"desc\": \"Hệ thống camera cho ảnh rõ nét trong nhiều điều kiện ánh sáng.\", \"icon\": \"fa-solid fa-camera\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=iPhone+15+128GB+Ch%C3%ADnh+H%C3%A3ng+VN%2FA+-+Camera\"}, {\"tag\": \"Hiệu năng\", \"title\": \"Vận hành mượt, pin dùng bền\", \"desc\": \"Chip xử lý và dung lượng pin cân bằng cho học tập, giải trí và chơi game.\", \"icon\": \"fa-solid fa-microchip\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=iPhone+15+128GB+Ch%C3%ADnh+H%C3%A3ng+VN%2FA+-+Hi%E1%BB%87u+n%C4%83ng\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=iPhone+%C4%90en\", \"quantity\": 20}, {\"name\": \"Hồng\", \"image\": \"https://placehold.co/600x600/db2777/ffffff/png?text=iPhone+H%E1%BB%93ng\", \"quantity\": 20}, {\"name\": \"Xanh\", \"image\": \"https://placehold.co/600x600/1d4ed8/ffffff/png?text=iPhone+Xanh\", \"quantity\": 20}]', 'slideshow', 60, 'iPhone 15 có Dynamic Island, camera chính 48MP và cổng USB-C. Chip A16 Bionic mạnh mẽ, thiết kế khung nhôm bền bỉ, phù hợp người dùng muốn trải nghiệm iOS ổn định với mức giá hợp lý.', '{\"Màn hình\": \"6.1 inch, Super Retina XDR OLED, Dynamic Island\", \"Vi xử lý (CPU)\": \"Apple A16 Bionic 6 nhân\", \"RAM\": \"6 GB\", \"Bộ nhớ trong\": \"128 GB\", \"Camera sau\": \"48 MP chính + 12 MP góc siêu rộng\", \"Camera trước\": \"12 MP TrueDepth\", \"Kết nối\": \"5G, Wi-Fi 6, Bluetooth 5.3, cổng USB-C\", \"Kháng nước, bụi\": \"IP68\"}', 'Hệ sinh thái Apple (AirPods, Apple Watch, iPad) & phụ kiện USB-C', 0, 1, 5.0, 0, NULL, '2026-11-26 20:34:11'),
(2, 1, 2, 'Samsung Galaxy A55 5G 8GB/128GB', 'samsung-galaxy-a55-5g-128gb', 9990000, 10990000, 'https://placehold.co/800x800/111827/ffffff/png?text=Samsung+Galaxy+A55+5G+8GB%2F128GB', '[{\"tag\": \"Thiết kế\", \"title\": \"Thiết kế hiện đại, cầm nắm thoải mái\", \"desc\": \"Ngoại hình tinh tế, hoàn thiện chắc chắn, phù hợp sử dụng hằng ngày.\", \"icon\": \"fa-solid fa-mobile-screen-button\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Samsung+Galaxy+A55+5G+8GB%2F128GB+-+Thi%E1%BA%BFt+k%E1%BA%BF\"}, {\"tag\": \"Camera\", \"title\": \"Chụp ảnh sắc nét, quay video mượt\", \"desc\": \"Hệ thống camera cho ảnh rõ nét trong nhiều điều kiện ánh sáng.\", \"icon\": \"fa-solid fa-camera\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Samsung+Galaxy+A55+5G+8GB%2F128GB+-+Camera\"}, {\"tag\": \"Hiệu năng\", \"title\": \"Vận hành mượt, pin dùng bền\", \"desc\": \"Chip xử lý và dung lượng pin cân bằng cho học tập, giải trí và chơi game.\", \"icon\": \"fa-solid fa-microchip\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Samsung+Galaxy+A55+5G+8GB%2F128GB+-+Hi%E1%BB%87u+n%C4%83ng\"}]', NULL, '[{\"name\": \"Xanh Navy\", \"image\": \"https://placehold.co/600x600/1d4ed8/ffffff/png?text=Samsung+Xanh+Navy\", \"quantity\": 35}, {\"name\": \"Tím Lilac\", \"image\": \"https://placehold.co/600x600/7c3aed/ffffff/png?text=Samsung+T%C3%ADm+Lilac\", \"quantity\": 35}]', 'slideshow', 70, 'Galaxy A55 5G có màn hình Super AMOLED 120Hz, camera chính 50MP chống rung quang học, pin 5000mAh và kháng nước IP67. Lựa chọn cân bằng trong tầm trung với cập nhật phần mềm dài hạn.', '{\"Màn hình\": \"6.6 inch, Super AMOLED, 120Hz\", \"Vi xử lý (CPU)\": \"Exynos 1480\", \"RAM\": \"8 GB\", \"Bộ nhớ trong\": \"128 GB\", \"Camera sau\": \"50 MP (OIS) + 12 MP góc siêu rộng + 5 MP macro\", \"Camera trước\": \"32 MP\", \"Dung lượng pin\": \"5000 mAh, sạc nhanh 25W\", \"Kháng nước, bụi\": \"IP67\"}', 'Hệ sinh thái Galaxy (Galaxy Buds, Galaxy Watch) & phụ kiện USB-C', 0, 0, 5.0, 0, NULL, '2026-11-26 20:34:12'),
(3, 1, 3, 'Xiaomi Redmi Note 13 Pro 5G 8GB/256GB', 'xiaomi-redmi-note-13-pro-5g-256gb', 8490000, 9490000, 'https://placehold.co/800x800/111827/ffffff/png?text=Xiaomi+Redmi+Note+13+Pro+5G+8GB%2F256GB', '[{\"tag\": \"Thiết kế\", \"title\": \"Thiết kế hiện đại, cầm nắm thoải mái\", \"desc\": \"Ngoại hình tinh tế, hoàn thiện chắc chắn, phù hợp sử dụng hằng ngày.\", \"icon\": \"fa-solid fa-mobile-screen-button\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Xiaomi+Redmi+Note+13+Pro+5G+8GB%2F256GB+-+Thi%E1%BA%BFt+k%E1%BA%BF\"}, {\"tag\": \"Camera\", \"title\": \"Chụp ảnh sắc nét, quay video mượt\", \"desc\": \"Hệ thống camera cho ảnh rõ nét trong nhiều điều kiện ánh sáng.\", \"icon\": \"fa-solid fa-camera\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Xiaomi+Redmi+Note+13+Pro+5G+8GB%2F256GB+-+Camera\"}, {\"tag\": \"Hiệu năng\", \"title\": \"Vận hành mượt, pin dùng bền\", \"desc\": \"Chip xử lý và dung lượng pin cân bằng cho học tập, giải trí và chơi game.\", \"icon\": \"fa-solid fa-microchip\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Xiaomi+Redmi+Note+13+Pro+5G+8GB%2F256GB+-+Hi%E1%BB%87u+n%C4%83ng\"}]', NULL, '[{\"name\": \"Đen Midnight\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=Xiaomi+%C4%90en+Midnight\", \"quantity\": 26}, {\"name\": \"Tím Aurora\", \"image\": \"https://placehold.co/600x600/7c3aed/ffffff/png?text=Xiaomi+T%C3%ADm+Aurora\", \"quantity\": 26}, {\"name\": \"Xanh Ocean\", \"image\": \"https://placehold.co/600x600/1d4ed8/ffffff/png?text=Xiaomi+Xanh+Ocean\", \"quantity\": 26}]', 'slideshow', 80, 'Redmi Note 13 Pro 5G nổi bật với camera chính 200MP, màn hình AMOLED 120Hz và sạc nhanh 67W. Cấu hình mạnh trong tầm giá, phù hợp người thích chụp ảnh và dùng nhiều ứng dụng.', '{\"Màn hình\": \"6.67 inch, AMOLED 1.5K, 120Hz\", \"Vi xử lý (CPU)\": \"Snapdragon 7s Gen 2\", \"RAM\": \"8 GB\", \"Bộ nhớ trong\": \"256 GB\", \"Camera sau\": \"200 MP (OIS) + 8 MP góc siêu rộng + 2 MP macro\", \"Camera trước\": \"16 MP\", \"Dung lượng pin\": \"5100 mAh, sạc nhanh 67W\", \"Kết nối\": \"5G, Wi-Fi, Bluetooth, NFC, USB-C\"}', 'Hệ sinh thái Xiaomi Smart Home & phụ kiện USB-C', 0, 1, 5.0, 0, NULL, '2026-11-26 20:34:12'),
(6, 2, 1, 'Tai nghe Apple AirPods Pro 2 (USB-C)', 'apple-airpods-pro-2-usb-c', 5490000, 6190000, 'https://placehold.co/800x800/111827/ffffff/png?text=Tai+nghe+Apple+AirPods+Pro+2+%28USB-C%29', '[{\"tag\": \"Âm thanh\", \"title\": \"Âm thanh sống động, chi tiết\", \"desc\": \"Tái tạo dải trầm, trung và cao cân bằng, nghe nhạc, xem phim đều thích.\", \"icon\": \"fa-solid fa-headphones-simple\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Apple+AirPods+Pro+2+%28USB-C%29+-+%C3%82m+thanh\"}, {\"tag\": \"Chống ồn\", \"title\": \"Giảm tiếng ồn xung quanh\", \"desc\": \"Tập trung hơn khi di chuyển, làm việc và học tập.\", \"icon\": \"fa-solid fa-volume-xmark\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Apple+AirPods+Pro+2+%28USB-C%29+-+Ch%E1%BB%91ng+%E1%BB%93n\"}, {\"tag\": \"Kết nối & Pin\", \"title\": \"Kết nối ổn định, dùng cả ngày\", \"desc\": \"Bluetooth ổn định cùng hộp sạc tiện lợi, dễ mang theo.\", \"icon\": \"fa-solid fa-battery-three-quarters\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Apple+AirPods+Pro+2+%28USB-C%29+-+K%E1%BA%BFt+n%E1%BB%91i+%26+Pin\"}]', NULL, '[{\"name\": \"Trắng\", \"image\": \"https://placehold.co/600x600/e5e7eb/ffffff/png?text=Tai+Tr%E1%BA%AFng\", \"quantity\": 60}]', 'slideshow', 60, 'AirPods Pro 2 với chip H2 cho khả năng chống ồn chủ động, chế độ xuyên âm và Âm thanh thích ứng. Hộp sạc USB-C hỗ trợ sạc không dây, kết nối nhanh với thiết bị Apple.', '{\"Chip xử lý\": \"Apple H2\", \"Chống ồn\": \"ANC chủ động, chế độ xuyên âm, Âm thanh thích ứng\", \"Kết nối\": \"Bluetooth 5.3\", \"Thời lượng pin\": \"Khoảng 6 giờ nghe, tối đa khoảng 30 giờ cùng hộp sạc\", \"Cổng sạc\": \"USB-C, hỗ trợ sạc không dây\", \"Chống nước, bụi\": \"IP54\"}', 'iPhone, iPad, Mac, Apple Watch (tốt nhất trong hệ sinh thái Apple)', 0, 1, 5.0, 0, NULL, '2026-11-26 20:34:12'),
(7, 2, 2, 'Tai nghe Samsung Galaxy Buds3 Pro', 'samsung-galaxy-buds3-pro', 5290000, 6490000, 'https://placehold.co/800x800/111827/ffffff/png?text=Tai+nghe+Samsung+Galaxy+Buds3+Pro', '[{\"tag\": \"Âm thanh\", \"title\": \"Âm thanh sống động, chi tiết\", \"desc\": \"Tái tạo dải trầm, trung và cao cân bằng, nghe nhạc, xem phim đều thích.\", \"icon\": \"fa-solid fa-headphones-simple\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Samsung+Galaxy+Buds3+Pro+-+%C3%82m+thanh\"}, {\"tag\": \"Chống ồn\", \"title\": \"Giảm tiếng ồn xung quanh\", \"desc\": \"Tập trung hơn khi di chuyển, làm việc và học tập.\", \"icon\": \"fa-solid fa-volume-xmark\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Samsung+Galaxy+Buds3+Pro+-+Ch%E1%BB%91ng+%E1%BB%93n\"}, {\"tag\": \"Kết nối & Pin\", \"title\": \"Kết nối ổn định, dùng cả ngày\", \"desc\": \"Bluetooth ổn định cùng hộp sạc tiện lợi, dễ mang theo.\", \"icon\": \"fa-solid fa-battery-three-quarters\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Samsung+Galaxy+Buds3+Pro+-+K%E1%BA%BFt+n%E1%BB%91i+%26+Pin\"}]', NULL, '[{\"name\": \"Bạc\", \"image\": \"https://placehold.co/600x600/9ca3af/ffffff/png?text=Tai+B%E1%BA%A1c\", \"quantity\": 25}, {\"name\": \"Trắng\", \"image\": \"https://placehold.co/600x600/e5e7eb/ffffff/png?text=Tai+Tr%E1%BA%AFng\", \"quantity\": 25}]', 'slideshow', 50, 'Galaxy Buds3 Pro có chống ồn thích ứng thông minh, âm thanh độ phân giải cao và thiết kế mới dạng thân dài. Tích hợp các tính năng Galaxy AI khi dùng cùng điện thoại Galaxy.', '{\"Chống ồn\": \"ANC thông minh thích ứng\", \"Âm thanh\": \"Loa hai đường tiếng, hỗ trợ Hi-Fi không dây\", \"Kết nối\": \"Bluetooth 5.4\", \"Thời lượng pin\": \"Khoảng 6 giờ (bật ANC), hộp sạc bổ sung thêm nhiều lần sạc\", \"Chống nước, bụi\": \"IP57\"}', 'Galaxy S/Z/A series (hỗ trợ đầy đủ nhất), Android và iPhone ở mức cơ bản', 0, 0, 5.0, 0, NULL, '2026-11-26 20:34:13'),
(8, 2, 5, 'Tai nghe True Wireless Sony WF-1000XM5 Chống Ồn', 'sony-wf-1000xm5', 5490000, 6490000, 'https://placehold.co/800x800/111827/ffffff/png?text=Tai+nghe+True+Wireless+Sony+WF-1000XM5+Ch%E1%BB%91', '[{\"tag\": \"Âm thanh\", \"title\": \"Âm thanh sống động, chi tiết\", \"desc\": \"Tái tạo dải trầm, trung và cao cân bằng, nghe nhạc, xem phim đều thích.\", \"icon\": \"fa-solid fa-headphones-simple\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+True+Wireless+Sony+WF-1000XM5+Ch%E1%BB%91+-+%C3%82m+thanh\"}, {\"tag\": \"Chống ồn\", \"title\": \"Giảm tiếng ồn xung quanh\", \"desc\": \"Tập trung hơn khi di chuyển, làm việc và học tập.\", \"icon\": \"fa-solid fa-volume-xmark\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+True+Wireless+Sony+WF-1000XM5+Ch%E1%BB%91+-+Ch%E1%BB%91ng+%E1%BB%93n\"}, {\"tag\": \"Kết nối & Pin\", \"title\": \"Kết nối ổn định, dùng cả ngày\", \"desc\": \"Bluetooth ổn định cùng hộp sạc tiện lợi, dễ mang theo.\", \"icon\": \"fa-solid fa-battery-three-quarters\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+True+Wireless+Sony+WF-1000XM5+Ch%E1%BB%91+-+K%E1%BA%BFt+n%E1%BB%91i+%26+Pin\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=Tai+%C4%90en\", \"quantity\": 22}, {\"name\": \"Bạc\", \"image\": \"https://placehold.co/600x600/9ca3af/ffffff/png?text=Tai+B%E1%BA%A1c\", \"quantity\": 22}]', 'slideshow', 45, 'Sony WF-1000XM5 là tai nghe true wireless cao cấp với chống ồn hàng đầu, hỗ trợ LDAC cho âm thanh độ phân giải cao, thiết kế nhỏ gọn, đeo êm trong thời gian dài.', '{\"Chống ồn\": \"ANC chủ động với bộ xử lý tích hợp\", \"Codec\": \"LDAC, AAC, SBC\", \"Kết nối\": \"Bluetooth 5.3, kết nối đa điểm\", \"Thời lượng pin\": \"Khoảng 8 giờ (bật ANC), tổng khoảng 24 giờ cùng hộp sạc\", \"Chống nước\": \"IPX4\"}', 'iPhone, Android, Máy tính bảng, Laptop', 0, 1, 5.0, 0, NULL, '2026-11-26 20:34:13'),
(11, 3, 2, 'Tai nghe có dây Samsung AKG cổng Type-C', 'tai-nghe-samsung-akg-type-c', 390000, 490000, 'https://placehold.co/800x800/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Samsung+AKG+c%E1%BB%95ng+Type-C', '[{\"tag\": \"Thiết kế\", \"title\": \"Gọn nhẹ, đeo thoải mái\", \"desc\": \"Thiết kế vừa vặn, hạn chế mỏi tai khi dùng lâu.\", \"icon\": \"fa-solid fa-headphones\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Samsung+AKG+c%E1%BB%95ng+Type-C+-+Thi%E1%BA%BFt+k%E1%BA%BF\"}, {\"tag\": \"Âm thanh\", \"title\": \"Âm thanh rõ ràng, dễ nghe\", \"desc\": \"Phù hợp nghe nhạc, học online và đàm thoại hằng ngày.\", \"icon\": \"fa-solid fa-music\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Samsung+AKG+c%E1%BB%95ng+Type-C+-+%C3%82m+thanh\"}, {\"tag\": \"Tiện dụng\", \"title\": \"Cắm là dùng, không cần pin\", \"desc\": \"Không cần ghép đôi, không lo hết pin, độ trễ thấp.\", \"icon\": \"fa-solid fa-plug\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Samsung+AKG+c%E1%BB%95ng+Type-C+-+Ti%E1%BB%87n+d%E1%BB%A5ng\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=Tai+%C4%90en\", \"quantity\": 100}]', 'slideshow', 100, 'Tai nghe nhét tai Samsung với âm thanh được tinh chỉnh bởi AKG, đầu cắm USB-C, tích hợp micro và nút điều khiển trên dây. Phù hợp nghe nhạc, xem video và đàm thoại.', '{\"Kết nối\": \"Có dây, đầu cắm USB-C\", \"Âm thanh\": \"Tinh chỉnh bởi AKG\", \"Điều khiển\": \"Nút bấm trên dây, micro đàm thoại\", \"Tương thích\": \"Galaxy và thiết bị Android USB-C\"}', 'Samsung Galaxy và thiết bị Android có cổng USB-C', 0, 0, 5.0, 0, NULL, '2026-11-26 20:34:13'),
(12, 3, 5, 'Tai nghe có dây Sony MDR-EX15AP giắc 3.5mm', 'tai-nghe-sony-mdr-ex15ap', 290000, 350000, 'https://placehold.co/800x800/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Sony+MDR-EX15AP+gi%E1%BA%AFc+3.5mm', '[{\"tag\": \"Thiết kế\", \"title\": \"Gọn nhẹ, đeo thoải mái\", \"desc\": \"Thiết kế vừa vặn, hạn chế mỏi tai khi dùng lâu.\", \"icon\": \"fa-solid fa-headphones\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Sony+MDR-EX15AP+gi%E1%BA%AFc+3.5mm+-+Thi%E1%BA%BFt+k%E1%BA%BF\"}, {\"tag\": \"Âm thanh\", \"title\": \"Âm thanh rõ ràng, dễ nghe\", \"desc\": \"Phù hợp nghe nhạc, học online và đàm thoại hằng ngày.\", \"icon\": \"fa-solid fa-music\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Sony+MDR-EX15AP+gi%E1%BA%AFc+3.5mm+-+%C3%82m+thanh\"}, {\"tag\": \"Tiện dụng\", \"title\": \"Cắm là dùng, không cần pin\", \"desc\": \"Không cần ghép đôi, không lo hết pin, độ trễ thấp.\", \"icon\": \"fa-solid fa-plug\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Sony+MDR-EX15AP+gi%E1%BA%AFc+3.5mm+-+Ti%E1%BB%87n+d%E1%BB%A5ng\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=Tai+%C4%90en\", \"quantity\": 40}, {\"name\": \"Trắng\", \"image\": \"https://placehold.co/600x600/e5e7eb/ffffff/png?text=Tai+Tr%E1%BA%AFng\", \"quantity\": 40}, {\"name\": \"Xanh\", \"image\": \"https://placehold.co/600x600/1d4ed8/ffffff/png?text=Tai+Xanh\", \"quantity\": 40}]', 'slideshow', 120, 'Sony MDR-EX15AP gọn nhẹ, âm bass rõ, có micro hỗ trợ nghe gọi và nút điều khiển. Nhiều màu sắc để lựa chọn, giá hợp lý.', '{\"Kết nối\": \"Giắc 3.5mm\", \"Driver\": \"9 mm\", \"Chiều dài dây\": \"Khoảng 1.2 m\", \"Micro\": \"Có, hỗ trợ đàm thoại\"}', 'Điện thoại, máy tính bảng, laptop có giắc 3.5mm', 0, 0, 5.0, 0, NULL, '2026-11-26 20:34:13'),
(13, 3, 3, 'Tai nghe có dây Xiaomi Dual Driver cổng Type-C', 'tai-nghe-xiaomi-dual-driver-type-c', 249000, 299000, 'https://placehold.co/800x800/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Xiaomi+Dual+Driver+c%E1%BB%95ng+Ty', '[{\"tag\": \"Thiết kế\", \"title\": \"Gọn nhẹ, đeo thoải mái\", \"desc\": \"Thiết kế vừa vặn, hạn chế mỏi tai khi dùng lâu.\", \"icon\": \"fa-solid fa-headphones\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Xiaomi+Dual+Driver+c%E1%BB%95ng+Ty+-+Thi%E1%BA%BFt+k%E1%BA%BF\"}, {\"tag\": \"Âm thanh\", \"title\": \"Âm thanh rõ ràng, dễ nghe\", \"desc\": \"Phù hợp nghe nhạc, học online và đàm thoại hằng ngày.\", \"icon\": \"fa-solid fa-music\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Xiaomi+Dual+Driver+c%E1%BB%95ng+Ty+-+%C3%82m+thanh\"}, {\"tag\": \"Tiện dụng\", \"title\": \"Cắm là dùng, không cần pin\", \"desc\": \"Không cần ghép đôi, không lo hết pin, độ trễ thấp.\", \"icon\": \"fa-solid fa-plug\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Xiaomi+Dual+Driver+c%E1%BB%95ng+Ty+-+Ti%E1%BB%87n+d%E1%BB%A5ng\"}]', NULL, '[{\"name\": \"Bạc\", \"image\": \"https://placehold.co/600x600/9ca3af/ffffff/png?text=Tai+B%E1%BA%A1c\", \"quantity\": 100}]', 'slideshow', 100, 'Tai nghe Xiaomi hai loa (dual driver) cho âm thanh chi tiết hơn tai nghe phổ thông, đầu cắm USB-C, có micro và nút điều khiển trên dây.', '{\"Kết nối\": \"Có dây, đầu cắm USB-C\", \"Hệ thống loa\": \"Hai loa (dual driver)\", \"Điều khiển\": \"Nút bấm trên dây + micro\", \"Tương thích\": \"Thiết bị có cổng USB-C\"}', 'Điện thoại, máy tính bảng, laptop có cổng USB-C', 0, 1, 5.0, 0, NULL, '2026-11-26 20:34:14'),
(16, 4, 1, 'Củ sạc nhanh Apple 20W cổng USB-C', 'cu-sac-apple-20w-usb-c', 590000, NULL, 'https://placehold.co/800x800/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Apple+20W+c%E1%BB%95ng+USB-C', '[{\"tag\": \"Công suất\", \"title\": \"Sạc nhanh ổn định\", \"desc\": \"Cấp nguồn hiệu quả cho thiết bị tương thích, tiết kiệm thời gian sạc.\", \"icon\": \"fa-solid fa-bolt\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Apple+20W+c%E1%BB%95ng+USB-C+-+C%C3%B4ng+su%E1%BA%A5t\"}, {\"tag\": \"An toàn\", \"title\": \"Bảo vệ thiết bị khi sạc\", \"desc\": \"Có cơ chế bảo vệ quá nhiệt, quá dòng và quá áp.\", \"icon\": \"fa-solid fa-shield-halved\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Apple+20W+c%E1%BB%95ng+USB-C+-+An+to%C3%A0n\"}, {\"tag\": \"Tiện lợi\", \"title\": \"Gọn nhẹ, dễ mang theo\", \"desc\": \"Thiết kế nhỏ gọn phù hợp mang đi học, đi làm và du lịch.\", \"icon\": \"fa-solid fa-suitcase-rolling\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Apple+20W+c%E1%BB%95ng+USB-C+-+Ti%E1%BB%87n+l%E1%BB%A3i\"}]', NULL, '[{\"name\": \"Trắng\", \"image\": \"https://placehold.co/600x600/e5e7eb/ffffff/png?text=C%E1%BB%A7+Tr%E1%BA%AFng\", \"quantity\": 150}]', 'slideshow', 150, 'Củ sạc Apple 20W USB-C cho phép sạc nhanh iPhone và iPad, thiết kế nhỏ gọn, tương thích tốt với cáp USB-C to Lightning và USB-C to USB-C.', '{\"Công suất\": \"20W\", \"Cổng ra\": \"1 x USB-C\", \"Chuẩn sạc\": \"USB Power Delivery\", \"Tương thích\": \"iPhone, iPad, AirPods\"}', 'iPhone 8 trở lên, iPad (sạc nhanh PD)', 0, 1, 5.0, 0, NULL, '2026-11-26 20:34:14'),
(17, 4, 2, 'Củ sạc nhanh Samsung 25W cổng USB-C', 'cu-sac-nhanh-samsung-25w', 450000, 590000, 'https://placehold.co/800x800/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Samsung+25W+c%E1%BB%95ng+USB-C', '[{\"tag\": \"Công suất\", \"title\": \"Sạc nhanh ổn định\", \"desc\": \"Cấp nguồn hiệu quả cho thiết bị tương thích, tiết kiệm thời gian sạc.\", \"icon\": \"fa-solid fa-bolt\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Samsung+25W+c%E1%BB%95ng+USB-C+-+C%C3%B4ng+su%E1%BA%A5t\"}, {\"tag\": \"An toàn\", \"title\": \"Bảo vệ thiết bị khi sạc\", \"desc\": \"Có cơ chế bảo vệ quá nhiệt, quá dòng và quá áp.\", \"icon\": \"fa-solid fa-shield-halved\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Samsung+25W+c%E1%BB%95ng+USB-C+-+An+to%C3%A0n\"}, {\"tag\": \"Tiện lợi\", \"title\": \"Gọn nhẹ, dễ mang theo\", \"desc\": \"Thiết kế nhỏ gọn phù hợp mang đi học, đi làm và du lịch.\", \"icon\": \"fa-solid fa-suitcase-rolling\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Samsung+25W+c%E1%BB%95ng+USB-C+-+Ti%E1%BB%87n+l%E1%BB%A3i\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=C%E1%BB%A7+%C4%90en\", \"quantity\": 75}, {\"name\": \"Trắng\", \"image\": \"https://placehold.co/600x600/e5e7eb/ffffff/png?text=C%E1%BB%A7+Tr%E1%BA%AFng\", \"quantity\": 75}]', 'slideshow', 150, 'Củ sạc nhanh Samsung 25W hỗ trợ chuẩn Power Delivery, sạc nhanh cho điện thoại Galaxy và nhiều thiết bị USB-C khác. Thiết kế nhỏ gọn, cắm là dùng.', '{\"Công suất\": \"25W\", \"Cổng ra\": \"1 x USB-C\", \"Chuẩn sạc\": \"USB Power Delivery, PPS\", \"Tương thích\": \"Galaxy và thiết bị USB-C PD\"}', 'Galaxy S/Z/A series và thiết bị USB-C chuẩn PD', 0, 0, 5.0, 0, NULL, '2026-11-26 20:34:14'),
(18, 4, 9, 'Củ sạc nhanh Ugreen Nexode 65W GaN 3 cổng', 'cu-sac-ugreen-nexode-65w-gan-3-cong', 790000, 990000, 'https://placehold.co/800x800/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Ugreen+Nexode+65W+GaN+3+c%E1%BB%95ng', '[{\"tag\": \"Công suất\", \"title\": \"Sạc nhanh ổn định\", \"desc\": \"Cấp nguồn hiệu quả cho thiết bị tương thích, tiết kiệm thời gian sạc.\", \"icon\": \"fa-solid fa-bolt\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Ugreen+Nexode+65W+GaN+3+c%E1%BB%95ng+-+C%C3%B4ng+su%E1%BA%A5t\"}, {\"tag\": \"An toàn\", \"title\": \"Bảo vệ thiết bị khi sạc\", \"desc\": \"Có cơ chế bảo vệ quá nhiệt, quá dòng và quá áp.\", \"icon\": \"fa-solid fa-shield-halved\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Ugreen+Nexode+65W+GaN+3+c%E1%BB%95ng+-+An+to%C3%A0n\"}, {\"tag\": \"Tiện lợi\", \"title\": \"Gọn nhẹ, dễ mang theo\", \"desc\": \"Thiết kế nhỏ gọn phù hợp mang đi học, đi làm và du lịch.\", \"icon\": \"fa-solid fa-suitcase-rolling\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Ugreen+Nexode+65W+GaN+3+c%E1%BB%95ng+-+Ti%E1%BB%87n+l%E1%BB%A3i\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=C%E1%BB%A7+%C4%90en\", \"quantity\": 100}]', 'slideshow', 100, 'Ugreen Nexode 65W ứng dụng công nghệ GaN, nhỏ gọn nhưng đủ sức sạc laptop, tablet và điện thoại cùng lúc qua 3 cổng. Bảo vệ nhiều lớp khi sạc.', '{\"Công nghệ\": \"GaN, sạc nhanh PD\", \"Tổng công suất\": \"65W\", \"Cổng ra\": \"2 x USB-C + 1 x USB-A\", \"Tương thích\": \"Laptop, máy tính bảng, điện thoại\"}', 'Laptop, iPad, iPhone, Samsung Galaxy, tai nghe', 0, 1, 5.0, 0, NULL, '2026-11-26 20:34:14'),
(21, 5, 7, 'Kính cường lực Baseus Diamond iPhone 16 Pro Max (bộ 2 miếng)', 'kinh-cuong-luc-baseus-diamond-iphone-16-pro-max', 190000, 250000, 'https://placehold.co/800x800/111827/ffffff/png?text=K%C3%ADnh+c%C6%B0%E1%BB%9Dng+l%E1%BB%B1c+Baseus+Diamond+iPhone+16+Pr', '[{\"tag\": \"Bảo vệ\", \"title\": \"Bảo vệ máy trước va chạm\", \"desc\": \"Hạn chế trầy xước và va đập trong quá trình sử dụng hằng ngày.\", \"icon\": \"fa-solid fa-shield-halved\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=K%C3%ADnh+c%C6%B0%E1%BB%9Dng+l%E1%BB%B1c+Baseus+Diamond+iPhone+16+Pr+-+B%E1%BA%A3o+v%E1%BB%87\"}, {\"tag\": \"Vừa vặn\", \"title\": \"Khoét chính xác từng chi tiết\", \"desc\": \"Cổng sạc, nút bấm và camera được tính toán vị trí chính xác.\", \"icon\": \"fa-solid fa-circle-check\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=K%C3%ADnh+c%C6%B0%E1%BB%9Dng+l%E1%BB%B1c+Baseus+Diamond+iPhone+16+Pr+-+V%E1%BB%ABa+v%E1%BA%B7n\"}, {\"tag\": \"Thẩm mỹ\", \"title\": \"Giữ vẻ đẹp nguyên bản\", \"desc\": \"Mỏng nhẹ, không làm cồng kềnh máy khi cầm trên tay.\", \"icon\": \"fa-solid fa-mobile-screen\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=K%C3%ADnh+c%C6%B0%E1%BB%9Dng+l%E1%BB%B1c+Baseus+Diamond+iPhone+16+Pr+-+Th%E1%BA%A9m+m%E1%BB%B9\"}]', NULL, '[{\"name\": \"Trong suốt\", \"image\": \"https://placehold.co/600x600/d1d5db/ffffff/png?text=K%C3%ADnh+Trong+su%E1%BB%91t\", \"quantity\": 150}]', 'slideshow', 150, 'Bộ 2 miếng kính cường lực Baseus Diamond cho iPhone 16 Pro Max, độ cứng 9H, chống trầy xước và hạn chế bám vân tay. Kèm khung hỗ trợ dán chính xác.', '{\"Chất liệu\": \"Kính cường lực, độ cứng 9H\", \"Số lượng\": \"2 miếng kèm khung hỗ trợ dán\", \"Tương thích\": \"iPhone 16 Pro Max\", \"Tính năng\": \"Chống trầy xước, hạn chế bám vân tay\"}', 'iPhone 16 Pro Max', 0, 0, 5.0, 0, NULL, '2026-11-26 20:34:15'),
(22, 5, 1, 'Ốp lưng Apple Silicone Case MagSafe iPhone 16 Pro Max', 'op-lung-apple-silicone-magsafe-iphone-16-pro-max', 1290000, NULL, 'https://placehold.co/800x800/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Apple+Silicone+Case+MagSafe+iPhone', '[{\"tag\": \"Bảo vệ\", \"title\": \"Bảo vệ máy trước va chạm\", \"desc\": \"Hạn chế trầy xước và va đập trong quá trình sử dụng hằng ngày.\", \"icon\": \"fa-solid fa-shield-halved\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Apple+Silicone+Case+MagSafe+iPhone+-+B%E1%BA%A3o+v%E1%BB%87\"}, {\"tag\": \"Vừa vặn\", \"title\": \"Khoét chính xác từng chi tiết\", \"desc\": \"Cổng sạc, nút bấm và camera được tính toán vị trí chính xác.\", \"icon\": \"fa-solid fa-circle-check\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Apple+Silicone+Case+MagSafe+iPhone+-+V%E1%BB%ABa+v%E1%BA%B7n\"}, {\"tag\": \"Thẩm mỹ\", \"title\": \"Giữ vẻ đẹp nguyên bản\", \"desc\": \"Mỏng nhẹ, không làm cồng kềnh máy khi cầm trên tay.\", \"icon\": \"fa-solid fa-mobile-screen\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Apple+Silicone+Case+MagSafe+iPhone+-+Th%E1%BA%A9m+m%E1%BB%B9\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=%E1%BB%90p+%C4%90en\", \"quantity\": 30}, {\"name\": \"Hồng\", \"image\": \"https://placehold.co/600x600/db2777/ffffff/png?text=%E1%BB%90p+H%E1%BB%93ng\", \"quantity\": 30}]', 'slideshow', 60, 'Ốp lưng silicone chính hãng Apple cho iPhone 16 Pro Max, bề mặt mềm mại, lớp lót sợi mềm bảo vệ máy, tương thích sạc MagSafe.', '{\"Chất liệu\": \"Silicone mềm, lớp lót sợi mềm\", \"MagSafe\": \"Hỗ trợ sạc và phụ kiện MagSafe\", \"Tương thích\": \"iPhone 16 Pro Max\", \"Thiết kế\": \"Ôm sát thân máy, khoét chính xác\"}', 'iPhone 16 Pro Max (hỗ trợ MagSafe)', 0, 0, 5.0, 0, NULL, '2026-11-26 20:34:15'),
(23, 5, 2, 'Ốp lưng Samsung Silicone Case Galaxy S24 Ultra', 'op-lung-samsung-silicone-galaxy-s24-ultra', 690000, 790000, 'https://placehold.co/800x800/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Samsung+Silicone+Case+Galaxy+S24+U', '[{\"tag\": \"Bảo vệ\", \"title\": \"Bảo vệ máy trước va chạm\", \"desc\": \"Hạn chế trầy xước và va đập trong quá trình sử dụng hằng ngày.\", \"icon\": \"fa-solid fa-shield-halved\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Samsung+Silicone+Case+Galaxy+S24+U+-+B%E1%BA%A3o+v%E1%BB%87\"}, {\"tag\": \"Vừa vặn\", \"title\": \"Khoét chính xác từng chi tiết\", \"desc\": \"Cổng sạc, nút bấm và camera được tính toán vị trí chính xác.\", \"icon\": \"fa-solid fa-circle-check\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Samsung+Silicone+Case+Galaxy+S24+U+-+V%E1%BB%ABa+v%E1%BA%B7n\"}, {\"tag\": \"Thẩm mỹ\", \"title\": \"Giữ vẻ đẹp nguyên bản\", \"desc\": \"Mỏng nhẹ, không làm cồng kềnh máy khi cầm trên tay.\", \"icon\": \"fa-solid fa-mobile-screen\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Samsung+Silicone+Case+Galaxy+S24+U+-+Th%E1%BA%A9m+m%E1%BB%B9\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=%E1%BB%90p+%C4%90en\", \"quantity\": 35}, {\"name\": \"Tím\", \"image\": \"https://placehold.co/600x600/7c3aed/ffffff/png?text=%E1%BB%90p+T%C3%ADm\", \"quantity\": 35}]', 'slideshow', 70, 'Ốp lưng silicone chính hãng Samsung cho Galaxy S24 Ultra, bề mặt mềm, cầm chắc tay, khoét chính xác cụm camera và S Pen.', '{\"Chất liệu\": \"Silicone mềm\", \"Tương thích\": \"Galaxy S24 Ultra\", \"Thiết kế\": \"Ôm sát, khoét chính xác camera và S Pen\", \"Bảo vệ\": \"Chống trầy xước, giảm lực va đập nhẹ\"}', 'Samsung Galaxy S24 Ultra', 0, 0, 5.0, 0, NULL, '2026-11-26 20:34:15'),
(26, 6, 3, 'Pin sạc dự phòng Xiaomi 20.000mAh 22.5W', 'pin-sac-du-phong-xiaomi-20000mah-22-5w', 590000, 750000, 'https://placehold.co/800x800/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Xiaomi+20.000mAh+22.5W', '[{\"tag\": \"Dung lượng\", \"title\": \"Dung lượng đủ dùng cả ngày\", \"desc\": \"Sạc đầy điện thoại nhiều lần khi đi xa, không lo hết pin.\", \"icon\": \"fa-solid fa-battery-three-quarters\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Xiaomi+20.000mAh+22.5W+-+Dung+l%C6%B0%E1%BB%A3ng\"}, {\"tag\": \"Sạc nhanh\", \"title\": \"Công suất sạc nhanh\", \"desc\": \"Hỗ trợ sạc nhanh cho điện thoại, máy tính bảng và phụ kiện.\", \"icon\": \"fa-solid fa-bolt\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Xiaomi+20.000mAh+22.5W+-+S%E1%BA%A1c+nhanh\"}, {\"tag\": \"An toàn\", \"title\": \"Nhiều lớp bảo vệ\", \"desc\": \"Bảo vệ quá nhiệt, quá dòng, ngắn mạch, sạc an toàn cho thiết bị.\", \"icon\": \"fa-solid fa-shield-halved\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Xiaomi+20.000mAh+22.5W+-+An+to%C3%A0n\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=Pin+%C4%90en\", \"quantity\": 50}, {\"name\": \"Bạc\", \"image\": \"https://placehold.co/600x600/9ca3af/ffffff/png?text=Pin+B%E1%BA%A1c\", \"quantity\": 50}]', 'slideshow', 100, 'Pin dự phòng Xiaomi dung lượng 20.000mAh, công suất tối đa 22.5W, nhiều cổng ra, sạc được cho nhiều thiết bị cùng lúc. Phù hợp cho chuyến đi dài ngày.', '{\"Dung lượng\": \"20.000 mAh\", \"Công suất ra tối đa\": \"22.5W\", \"Cổng kết nối\": \"USB-C và USB-A\", \"Tính năng an toàn\": \"Bảo vệ quá nhiệt, quá dòng, ngắn mạch\"}', 'iPhone, Android, máy tính bảng, tai nghe, phụ kiện USB', 0, 1, 5.0, 0, NULL, '2026-11-26 20:34:15'),
(27, 6, 7, 'Pin sạc dự phòng Baseus Blade 20.000mAh 100W', 'pin-sac-du-phong-baseus-blade-20000mah-100w', 1390000, 1690000, 'https://placehold.co/800x800/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Baseus+Blade+20.000mAh+10', '[{\"tag\": \"Dung lượng\", \"title\": \"Dung lượng đủ dùng cả ngày\", \"desc\": \"Sạc đầy điện thoại nhiều lần khi đi xa, không lo hết pin.\", \"icon\": \"fa-solid fa-battery-three-quarters\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Baseus+Blade+20.000mAh+10+-+Dung+l%C6%B0%E1%BB%A3ng\"}, {\"tag\": \"Sạc nhanh\", \"title\": \"Công suất sạc nhanh\", \"desc\": \"Hỗ trợ sạc nhanh cho điện thoại, máy tính bảng và phụ kiện.\", \"icon\": \"fa-solid fa-bolt\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Baseus+Blade+20.000mAh+10+-+S%E1%BA%A1c+nhanh\"}, {\"tag\": \"An toàn\", \"title\": \"Nhiều lớp bảo vệ\", \"desc\": \"Bảo vệ quá nhiệt, quá dòng, ngắn mạch, sạc an toàn cho thiết bị.\", \"icon\": \"fa-solid fa-shield-halved\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Baseus+Blade+20.000mAh+10+-+An+to%C3%A0n\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=Pin+%C4%90en\", \"quantity\": 30}, {\"name\": \"Xám\", \"image\": \"https://placehold.co/600x600/6b7280/ffffff/png?text=Pin+X%C3%A1m\", \"quantity\": 30}]', 'slideshow', 60, 'Baseus Blade 20.000mAh có thiết kế mỏng dạng phiến, công suất tối đa 100W đủ sạc laptop, kèm màn hình hiển thị phần trăm pin tiện theo dõi.', '{\"Dung lượng\": \"20.000 mAh\", \"Công suất ra tối đa\": \"100W\", \"Cổng kết nối\": \"USB-C và USB-A, hỗ trợ sạc laptop\", \"Thiết kế\": \"Mỏng dạng phiến, màn hình hiển thị pin\"}', 'Laptop, iPad, iPhone, Samsung Galaxy', 0, 0, 5.0, 0, NULL, '2026-11-26 20:34:15'),
(28, 6, 6, 'Pin sạc dự phòng Anker 737 24.000mAh 140W', 'pin-sac-du-phong-anker-737-24000mah-140w', 2790000, 3290000, 'https://placehold.co/800x800/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Anker+737+24.000mAh+140W', '[{\"tag\": \"Dung lượng\", \"title\": \"Dung lượng đủ dùng cả ngày\", \"desc\": \"Sạc đầy điện thoại nhiều lần khi đi xa, không lo hết pin.\", \"icon\": \"fa-solid fa-battery-three-quarters\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Anker+737+24.000mAh+140W+-+Dung+l%C6%B0%E1%BB%A3ng\"}, {\"tag\": \"Sạc nhanh\", \"title\": \"Công suất sạc nhanh\", \"desc\": \"Hỗ trợ sạc nhanh cho điện thoại, máy tính bảng và phụ kiện.\", \"icon\": \"fa-solid fa-bolt\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Anker+737+24.000mAh+140W+-+S%E1%BA%A1c+nhanh\"}, {\"tag\": \"An toàn\", \"title\": \"Nhiều lớp bảo vệ\", \"desc\": \"Bảo vệ quá nhiệt, quá dòng, ngắn mạch, sạc an toàn cho thiết bị.\", \"icon\": \"fa-solid fa-shield-halved\", \"image\": \"https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Anker+737+24.000mAh+140W+-+An+to%C3%A0n\"}]', NULL, '[{\"name\": \"Đen\", \"image\": \"https://placehold.co/600x600/111827/ffffff/png?text=Pin+%C4%90en\", \"quantity\": 40}]', 'slideshow', 40, 'Anker 737 (PowerCore 24K) dung lượng 24.000mAh, công suất tối đa 140W, màn hình thông minh hiển thị công suất và thời gian. Phù hợp người dùng laptop thường xuyên di chuyển.', '{\"Dung lượng\": \"24.000 mAh\", \"Công suất ra tối đa\": \"140W\", \"Cổng kết nối\": \"2 x USB-C + 1 x USB-A\", \"Màn hình\": \"Màn hình thông minh hiển thị công suất, thời gian\"}', 'Laptop, MacBook, iPad, iPhone, Samsung Galaxy', 1, 0, 5.0, 0, NULL, '2026-11-26 20:34:16');

-- -------------------------------------------------------------
-- Dữ liệu mẫu bảng `product_attributes` (88 bản ghi)
-- -------------------------------------------------------------
INSERT INTO `product_attributes` (`id`, `product_id`, `name`, `value`, `group_name`, `sort_order`) VALUES
(1, 1, 'Màn hình', '6.1 inch, Super Retina XDR OLED, Dynamic Island', 'Màn hình & Hiển thị', 1),
(2, 1, 'Vi xử lý (CPU)', 'Apple A16 Bionic 6 nhân', 'Hiệu năng', 2),
(3, 1, 'RAM', '6 GB', 'Hiệu năng', 3),
(4, 1, 'Bộ nhớ trong', '128 GB', 'Bộ nhớ', 4),
(5, 1, 'Camera sau', '48 MP chính + 12 MP góc siêu rộng', 'Camera', 5),
(6, 1, 'Camera trước', '12 MP TrueDepth', 'Camera', 6),
(7, 1, 'Kết nối', '5G, Wi-Fi 6, Bluetooth 5.3, cổng USB-C', 'Kết nối', 7),
(8, 1, 'Kháng nước, bụi', 'IP68', 'Thiết kế', 8),
(9, 2, 'Màn hình', '6.6 inch, Super AMOLED, 120Hz', 'Màn hình & Hiển thị', 1),
(10, 2, 'Vi xử lý (CPU)', 'Exynos 1480', 'Hiệu năng', 2),
(11, 2, 'RAM', '8 GB', 'Hiệu năng', 3),
(12, 2, 'Bộ nhớ trong', '128 GB', 'Bộ nhớ', 4),
(13, 2, 'Camera sau', '50 MP (OIS) + 12 MP góc siêu rộng + 5 MP macro', 'Camera', 5),
(14, 2, 'Camera trước', '32 MP', 'Camera', 6),
(15, 2, 'Dung lượng pin', '5000 mAh, sạc nhanh 25W', 'Pin & Sạc', 7),
(16, 2, 'Kháng nước, bụi', 'IP67', 'Thiết kế', 8),
(17, 3, 'Màn hình', '6.67 inch, AMOLED 1.5K, 120Hz', 'Màn hình & Hiển thị', 1),
(18, 3, 'Vi xử lý (CPU)', 'Snapdragon 7s Gen 2', 'Hiệu năng', 2),
(19, 3, 'RAM', '8 GB', 'Hiệu năng', 3),
(20, 3, 'Bộ nhớ trong', '256 GB', 'Bộ nhớ', 4),
(21, 3, 'Camera sau', '200 MP (OIS) + 8 MP góc siêu rộng + 2 MP macro', 'Camera', 5),
(22, 3, 'Camera trước', '16 MP', 'Camera', 6),
(23, 3, 'Dung lượng pin', '5100 mAh, sạc nhanh 67W', 'Pin & Sạc', 7),
(24, 3, 'Kết nối', '5G, Wi-Fi, Bluetooth, NFC, USB-C', 'Kết nối', 8),
(41, 6, 'Chip xử lý', 'Apple H2', 'Âm thanh', 1),
(42, 6, 'Chống ồn', 'ANC chủ động, chế độ xuyên âm, Âm thanh thích ứng', 'Âm thanh', 2),
(43, 6, 'Kết nối', 'Bluetooth 5.3', 'Kết nối', 3),
(44, 6, 'Thời lượng pin', 'Khoảng 6 giờ nghe, tối đa khoảng 30 giờ cùng hộp sạc', 'Pin & Sạc', 4),
(45, 6, 'Cổng sạc', 'USB-C, hỗ trợ sạc không dây', 'Pin & Sạc', 5),
(46, 6, 'Chống nước, bụi', 'IP54', 'Thiết kế', 6),
(47, 7, 'Chống ồn', 'ANC thông minh thích ứng', 'Âm thanh', 1),
(48, 7, 'Âm thanh', 'Loa hai đường tiếng, hỗ trợ Hi-Fi không dây', 'Âm thanh', 2),
(49, 7, 'Kết nối', 'Bluetooth 5.4', 'Kết nối', 3),
(50, 7, 'Thời lượng pin', 'Khoảng 6 giờ (bật ANC), hộp sạc bổ sung thêm nhiều lần sạc', 'Pin & Sạc', 4),
(51, 7, 'Chống nước, bụi', 'IP57', 'Thiết kế', 5),
(52, 8, 'Chống ồn', 'ANC chủ động với bộ xử lý tích hợp', 'Âm thanh', 1),
(53, 8, 'Codec', 'LDAC, AAC, SBC', 'Âm thanh', 2),
(54, 8, 'Kết nối', 'Bluetooth 5.3, kết nối đa điểm', 'Kết nối', 3),
(55, 8, 'Thời lượng pin', 'Khoảng 8 giờ (bật ANC), tổng khoảng 24 giờ cùng hộp sạc', 'Pin & Sạc', 4),
(56, 8, 'Chống nước', 'IPX4', 'Thiết kế', 5),
(67, 11, 'Kết nối', 'Có dây, đầu cắm USB-C', 'Kết nối', 1),
(68, 11, 'Âm thanh', 'Tinh chỉnh bởi AKG', 'Âm thanh', 2),
(69, 11, 'Điều khiển', 'Nút bấm trên dây, micro đàm thoại', 'Tính năng', 3),
(70, 11, 'Tương thích', 'Galaxy và thiết bị Android USB-C', 'Tương thích', 4),
(71, 12, 'Kết nối', 'Giắc 3.5mm', 'Kết nối', 1),
(72, 12, 'Driver', '9 mm', 'Âm thanh', 2),
(73, 12, 'Chiều dài dây', 'Khoảng 1.2 m', 'Thiết kế', 3),
(74, 12, 'Micro', 'Có, hỗ trợ đàm thoại', 'Tính năng', 4),
(75, 13, 'Kết nối', 'Có dây, đầu cắm USB-C', 'Kết nối', 1),
(76, 13, 'Hệ thống loa', 'Hai loa (dual driver)', 'Âm thanh', 2),
(77, 13, 'Điều khiển', 'Nút bấm trên dây + micro', 'Tính năng', 3),
(78, 13, 'Tương thích', 'Thiết bị có cổng USB-C', 'Tương thích', 4),
(87, 16, 'Công suất', '20W', 'Công suất', 1),
(88, 16, 'Cổng ra', '1 x USB-C', 'Cổng kết nối', 2),
(89, 16, 'Chuẩn sạc', 'USB Power Delivery', 'Công nghệ', 3),
(90, 16, 'Tương thích', 'iPhone, iPad, AirPods', 'Tương thích', 4),
(91, 17, 'Công suất', '25W', 'Công suất', 1),
(92, 17, 'Cổng ra', '1 x USB-C', 'Cổng kết nối', 2),
(93, 17, 'Chuẩn sạc', 'USB Power Delivery, PPS', 'Công nghệ', 3),
(94, 17, 'Tương thích', 'Galaxy và thiết bị USB-C PD', 'Tương thích', 4),
(95, 18, 'Công nghệ', 'GaN, sạc nhanh PD', 'Công nghệ', 1),
(96, 18, 'Tổng công suất', '65W', 'Công suất', 2),
(97, 18, 'Cổng ra', '2 x USB-C + 1 x USB-A', 'Cổng kết nối', 3),
(98, 18, 'Tương thích', 'Laptop, máy tính bảng, điện thoại', 'Tương thích', 4),
(107, 21, 'Chất liệu', 'Kính cường lực, độ cứng 9H', 'Chất liệu', 1),
(108, 21, 'Số lượng', '2 miếng kèm khung hỗ trợ dán', 'Phụ kiện', 2),
(109, 21, 'Tương thích', 'iPhone 16 Pro Max', 'Tương thích', 3),
(110, 21, 'Tính năng', 'Chống trầy xước, hạn chế bám vân tay', 'Bảo vệ', 4),
(111, 22, 'Chất liệu', 'Silicone mềm, lớp lót sợi mềm', 'Chất liệu', 1),
(112, 22, 'MagSafe', 'Hỗ trợ sạc và phụ kiện MagSafe', 'Tính năng', 2),
(113, 22, 'Tương thích', 'iPhone 16 Pro Max', 'Tương thích', 3),
(114, 22, 'Thiết kế', 'Ôm sát thân máy, khoét chính xác', 'Thiết kế', 4),
(115, 23, 'Chất liệu', 'Silicone mềm', 'Chất liệu', 1),
(116, 23, 'Tương thích', 'Galaxy S24 Ultra', 'Tương thích', 2),
(117, 23, 'Thiết kế', 'Ôm sát, khoét chính xác camera và S Pen', 'Thiết kế', 3),
(118, 23, 'Bảo vệ', 'Chống trầy xước, giảm lực va đập nhẹ', 'Bảo vệ', 4),
(127, 26, 'Dung lượng', '20.000 mAh', 'Pin', 1),
(128, 26, 'Công suất ra tối đa', '22.5W', 'Công suất', 2),
(129, 26, 'Cổng kết nối', 'USB-C và USB-A', 'Cổng kết nối', 3),
(130, 26, 'Tính năng an toàn', 'Bảo vệ quá nhiệt, quá dòng, ngắn mạch', 'An toàn', 4),
(131, 27, 'Dung lượng', '20.000 mAh', 'Pin', 1),
(132, 27, 'Công suất ra tối đa', '100W', 'Công suất', 2),
(133, 27, 'Cổng kết nối', 'USB-C và USB-A, hỗ trợ sạc laptop', 'Cổng kết nối', 3),
(134, 27, 'Thiết kế', 'Mỏng dạng phiến, màn hình hiển thị pin', 'Thiết kế', 4),
(135, 28, 'Dung lượng', '24.000 mAh', 'Pin', 1),
(136, 28, 'Công suất ra tối đa', '140W', 'Công suất', 2),
(137, 28, 'Cổng kết nối', '2 x USB-C + 1 x USB-A', 'Cổng kết nối', 3),
(138, 28, 'Màn hình', 'Màn hình thông minh hiển thị công suất, thời gian', 'Tính năng', 4);

-- -------------------------------------------------------------
-- Dữ liệu mẫu bảng `product_galleries` (54 bản ghi)
-- -------------------------------------------------------------
INSERT INTO `product_galleries` (`id`, `product_id`, `image_url`, `title`, `tag`, `description`, `sort_order`, `created_at`) VALUES
(1, 1, 'https://placehold.co/800x600/111827/ffffff/png?text=iPhone+15+128GB+Ch%C3%ADnh+H%C3%A3ng+VN%2FA+-+Thi%E1%BA%BFt+k%E1%BA%BF', 'Thiết kế hiện đại, cầm nắm thoải mái', 'Thiết kế', 'Ngoại hình tinh tế, hoàn thiện chắc chắn, phù hợp sử dụng hằng ngày.', 1, '2026-11-26 20:34:11'),
(2, 1, 'https://placehold.co/800x600/111827/ffffff/png?text=iPhone+15+128GB+Ch%C3%ADnh+H%C3%A3ng+VN%2FA+-+Camera', 'Chụp ảnh sắc nét, quay video mượt', 'Camera', 'Hệ thống camera cho ảnh rõ nét trong nhiều điều kiện ánh sáng.', 2, '2026-11-26 20:34:11'),
(3, 1, 'https://placehold.co/800x600/111827/ffffff/png?text=iPhone+15+128GB+Ch%C3%ADnh+H%C3%A3ng+VN%2FA+-+Hi%E1%BB%87u+n%C4%83ng', 'Vận hành mượt, pin dùng bền', 'Hiệu năng', 'Chip xử lý và dung lượng pin cân bằng cho học tập, giải trí và chơi game.', 3, '2026-11-26 20:34:11'),
(4, 2, 'https://placehold.co/800x600/111827/ffffff/png?text=Samsung+Galaxy+A55+5G+8GB%2F128GB+-+Thi%E1%BA%BFt+k%E1%BA%BF', 'Thiết kế hiện đại, cầm nắm thoải mái', 'Thiết kế', 'Ngoại hình tinh tế, hoàn thiện chắc chắn, phù hợp sử dụng hằng ngày.', 1, '2026-11-26 20:34:12'),
(5, 2, 'https://placehold.co/800x600/111827/ffffff/png?text=Samsung+Galaxy+A55+5G+8GB%2F128GB+-+Camera', 'Chụp ảnh sắc nét, quay video mượt', 'Camera', 'Hệ thống camera cho ảnh rõ nét trong nhiều điều kiện ánh sáng.', 2, '2026-11-26 20:34:12'),
(6, 2, 'https://placehold.co/800x600/111827/ffffff/png?text=Samsung+Galaxy+A55+5G+8GB%2F128GB+-+Hi%E1%BB%87u+n%C4%83ng', 'Vận hành mượt, pin dùng bền', 'Hiệu năng', 'Chip xử lý và dung lượng pin cân bằng cho học tập, giải trí và chơi game.', 3, '2026-11-26 20:34:12'),
(7, 3, 'https://placehold.co/800x600/111827/ffffff/png?text=Xiaomi+Redmi+Note+13+Pro+5G+8GB%2F256GB+-+Thi%E1%BA%BFt+k%E1%BA%BF', 'Thiết kế hiện đại, cầm nắm thoải mái', 'Thiết kế', 'Ngoại hình tinh tế, hoàn thiện chắc chắn, phù hợp sử dụng hằng ngày.', 1, '2026-11-26 20:34:12'),
(8, 3, 'https://placehold.co/800x600/111827/ffffff/png?text=Xiaomi+Redmi+Note+13+Pro+5G+8GB%2F256GB+-+Camera', 'Chụp ảnh sắc nét, quay video mượt', 'Camera', 'Hệ thống camera cho ảnh rõ nét trong nhiều điều kiện ánh sáng.', 2, '2026-11-26 20:34:12'),
(9, 3, 'https://placehold.co/800x600/111827/ffffff/png?text=Xiaomi+Redmi+Note+13+Pro+5G+8GB%2F256GB+-+Hi%E1%BB%87u+n%C4%83ng', 'Vận hành mượt, pin dùng bền', 'Hiệu năng', 'Chip xử lý và dung lượng pin cân bằng cho học tập, giải trí và chơi game.', 3, '2026-11-26 20:34:12'),
(16, 6, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Apple+AirPods+Pro+2+%28USB-C%29+-+%C3%82m+thanh', 'Âm thanh sống động, chi tiết', 'Âm thanh', 'Tái tạo dải trầm, trung và cao cân bằng, nghe nhạc, xem phim đều thích.', 1, '2026-11-26 20:34:13'),
(17, 6, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Apple+AirPods+Pro+2+%28USB-C%29+-+Ch%E1%BB%91ng+%E1%BB%93n', 'Giảm tiếng ồn xung quanh', 'Chống ồn', 'Tập trung hơn khi di chuyển, làm việc và học tập.', 2, '2026-11-26 20:34:13'),
(18, 6, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Apple+AirPods+Pro+2+%28USB-C%29+-+K%E1%BA%BFt+n%E1%BB%91i+%26+Pin', 'Kết nối ổn định, dùng cả ngày', 'Kết nối & Pin', 'Bluetooth ổn định cùng hộp sạc tiện lợi, dễ mang theo.', 3, '2026-11-26 20:34:13'),
(19, 7, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Samsung+Galaxy+Buds3+Pro+-+%C3%82m+thanh', 'Âm thanh sống động, chi tiết', 'Âm thanh', 'Tái tạo dải trầm, trung và cao cân bằng, nghe nhạc, xem phim đều thích.', 1, '2026-11-26 20:34:13'),
(20, 7, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Samsung+Galaxy+Buds3+Pro+-+Ch%E1%BB%91ng+%E1%BB%93n', 'Giảm tiếng ồn xung quanh', 'Chống ồn', 'Tập trung hơn khi di chuyển, làm việc và học tập.', 2, '2026-11-26 20:34:13'),
(21, 7, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+Samsung+Galaxy+Buds3+Pro+-+K%E1%BA%BFt+n%E1%BB%91i+%26+Pin', 'Kết nối ổn định, dùng cả ngày', 'Kết nối & Pin', 'Bluetooth ổn định cùng hộp sạc tiện lợi, dễ mang theo.', 3, '2026-11-26 20:34:13'),
(22, 8, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+True+Wireless+Sony+WF-1000XM5+Ch%E1%BB%91+-+%C3%82m+thanh', 'Âm thanh sống động, chi tiết', 'Âm thanh', 'Tái tạo dải trầm, trung và cao cân bằng, nghe nhạc, xem phim đều thích.', 1, '2026-11-26 20:34:13'),
(23, 8, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+True+Wireless+Sony+WF-1000XM5+Ch%E1%BB%91+-+Ch%E1%BB%91ng+%E1%BB%93n', 'Giảm tiếng ồn xung quanh', 'Chống ồn', 'Tập trung hơn khi di chuyển, làm việc và học tập.', 2, '2026-11-26 20:34:13'),
(24, 8, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+True+Wireless+Sony+WF-1000XM5+Ch%E1%BB%91+-+K%E1%BA%BFt+n%E1%BB%91i+%26+Pin', 'Kết nối ổn định, dùng cả ngày', 'Kết nối & Pin', 'Bluetooth ổn định cùng hộp sạc tiện lợi, dễ mang theo.', 3, '2026-11-26 20:34:13'),
(31, 11, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Samsung+AKG+c%E1%BB%95ng+Type-C+-+Thi%E1%BA%BFt+k%E1%BA%BF', 'Gọn nhẹ, đeo thoải mái', 'Thiết kế', 'Thiết kế vừa vặn, hạn chế mỏi tai khi dùng lâu.', 1, '2026-11-26 20:34:13'),
(32, 11, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Samsung+AKG+c%E1%BB%95ng+Type-C+-+%C3%82m+thanh', 'Âm thanh rõ ràng, dễ nghe', 'Âm thanh', 'Phù hợp nghe nhạc, học online và đàm thoại hằng ngày.', 2, '2026-11-26 20:34:13'),
(33, 11, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Samsung+AKG+c%E1%BB%95ng+Type-C+-+Ti%E1%BB%87n+d%E1%BB%A5ng', 'Cắm là dùng, không cần pin', 'Tiện dụng', 'Không cần ghép đôi, không lo hết pin, độ trễ thấp.', 3, '2026-11-26 20:34:13'),
(34, 12, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Sony+MDR-EX15AP+gi%E1%BA%AFc+3.5mm+-+Thi%E1%BA%BFt+k%E1%BA%BF', 'Gọn nhẹ, đeo thoải mái', 'Thiết kế', 'Thiết kế vừa vặn, hạn chế mỏi tai khi dùng lâu.', 1, '2026-11-26 20:34:13'),
(35, 12, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Sony+MDR-EX15AP+gi%E1%BA%AFc+3.5mm+-+%C3%82m+thanh', 'Âm thanh rõ ràng, dễ nghe', 'Âm thanh', 'Phù hợp nghe nhạc, học online và đàm thoại hằng ngày.', 2, '2026-11-26 20:34:14'),
(36, 12, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Sony+MDR-EX15AP+gi%E1%BA%AFc+3.5mm+-+Ti%E1%BB%87n+d%E1%BB%A5ng', 'Cắm là dùng, không cần pin', 'Tiện dụng', 'Không cần ghép đôi, không lo hết pin, độ trễ thấp.', 3, '2026-11-26 20:34:14'),
(37, 13, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Xiaomi+Dual+Driver+c%E1%BB%95ng+Ty+-+Thi%E1%BA%BFt+k%E1%BA%BF', 'Gọn nhẹ, đeo thoải mái', 'Thiết kế', 'Thiết kế vừa vặn, hạn chế mỏi tai khi dùng lâu.', 1, '2026-11-26 20:34:14'),
(38, 13, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Xiaomi+Dual+Driver+c%E1%BB%95ng+Ty+-+%C3%82m+thanh', 'Âm thanh rõ ràng, dễ nghe', 'Âm thanh', 'Phù hợp nghe nhạc, học online và đàm thoại hằng ngày.', 2, '2026-11-26 20:34:14'),
(39, 13, 'https://placehold.co/800x600/111827/ffffff/png?text=Tai+nghe+c%C3%B3+d%C3%A2y+Xiaomi+Dual+Driver+c%E1%BB%95ng+Ty+-+Ti%E1%BB%87n+d%E1%BB%A5ng', 'Cắm là dùng, không cần pin', 'Tiện dụng', 'Không cần ghép đôi, không lo hết pin, độ trễ thấp.', 3, '2026-11-26 20:34:14'),
(46, 16, 'https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Apple+20W+c%E1%BB%95ng+USB-C+-+C%C3%B4ng+su%E1%BA%A5t', 'Sạc nhanh ổn định', 'Công suất', 'Cấp nguồn hiệu quả cho thiết bị tương thích, tiết kiệm thời gian sạc.', 1, '2026-11-26 20:34:14'),
(47, 16, 'https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Apple+20W+c%E1%BB%95ng+USB-C+-+An+to%C3%A0n', 'Bảo vệ thiết bị khi sạc', 'An toàn', 'Có cơ chế bảo vệ quá nhiệt, quá dòng và quá áp.', 2, '2026-11-26 20:34:14'),
(48, 16, 'https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Apple+20W+c%E1%BB%95ng+USB-C+-+Ti%E1%BB%87n+l%E1%BB%A3i', 'Gọn nhẹ, dễ mang theo', 'Tiện lợi', 'Thiết kế nhỏ gọn phù hợp mang đi học, đi làm và du lịch.', 3, '2026-11-26 20:34:14'),
(49, 17, 'https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Samsung+25W+c%E1%BB%95ng+USB-C+-+C%C3%B4ng+su%E1%BA%A5t', 'Sạc nhanh ổn định', 'Công suất', 'Cấp nguồn hiệu quả cho thiết bị tương thích, tiết kiệm thời gian sạc.', 1, '2026-11-26 20:34:14'),
(50, 17, 'https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Samsung+25W+c%E1%BB%95ng+USB-C+-+An+to%C3%A0n', 'Bảo vệ thiết bị khi sạc', 'An toàn', 'Có cơ chế bảo vệ quá nhiệt, quá dòng và quá áp.', 2, '2026-11-26 20:34:14'),
(51, 17, 'https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Samsung+25W+c%E1%BB%95ng+USB-C+-+Ti%E1%BB%87n+l%E1%BB%A3i', 'Gọn nhẹ, dễ mang theo', 'Tiện lợi', 'Thiết kế nhỏ gọn phù hợp mang đi học, đi làm và du lịch.', 3, '2026-11-26 20:34:14'),
(52, 18, 'https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Ugreen+Nexode+65W+GaN+3+c%E1%BB%95ng+-+C%C3%B4ng+su%E1%BA%A5t', 'Sạc nhanh ổn định', 'Công suất', 'Cấp nguồn hiệu quả cho thiết bị tương thích, tiết kiệm thời gian sạc.', 1, '2026-11-26 20:34:14'),
(53, 18, 'https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Ugreen+Nexode+65W+GaN+3+c%E1%BB%95ng+-+An+to%C3%A0n', 'Bảo vệ thiết bị khi sạc', 'An toàn', 'Có cơ chế bảo vệ quá nhiệt, quá dòng và quá áp.', 2, '2026-11-26 20:34:14'),
(54, 18, 'https://placehold.co/800x600/111827/ffffff/png?text=C%E1%BB%A7+s%E1%BA%A1c+nhanh+Ugreen+Nexode+65W+GaN+3+c%E1%BB%95ng+-+Ti%E1%BB%87n+l%E1%BB%A3i', 'Gọn nhẹ, dễ mang theo', 'Tiện lợi', 'Thiết kế nhỏ gọn phù hợp mang đi học, đi làm và du lịch.', 3, '2026-11-26 20:34:14'),
(61, 21, 'https://placehold.co/800x600/111827/ffffff/png?text=K%C3%ADnh+c%C6%B0%E1%BB%9Dng+l%E1%BB%B1c+Baseus+Diamond+iPhone+16+Pr+-+B%E1%BA%A3o+v%E1%BB%87', 'Bảo vệ máy trước va chạm', 'Bảo vệ', 'Hạn chế trầy xước và va đập trong quá trình sử dụng hằng ngày.', 1, '2026-11-26 20:34:15'),
(62, 21, 'https://placehold.co/800x600/111827/ffffff/png?text=K%C3%ADnh+c%C6%B0%E1%BB%9Dng+l%E1%BB%B1c+Baseus+Diamond+iPhone+16+Pr+-+V%E1%BB%ABa+v%E1%BA%B7n', 'Khoét chính xác từng chi tiết', 'Vừa vặn', 'Cổng sạc, nút bấm và camera được tính toán vị trí chính xác.', 2, '2026-11-26 20:34:15'),
(63, 21, 'https://placehold.co/800x600/111827/ffffff/png?text=K%C3%ADnh+c%C6%B0%E1%BB%9Dng+l%E1%BB%B1c+Baseus+Diamond+iPhone+16+Pr+-+Th%E1%BA%A9m+m%E1%BB%B9', 'Giữ vẻ đẹp nguyên bản', 'Thẩm mỹ', 'Mỏng nhẹ, không làm cồng kềnh máy khi cầm trên tay.', 3, '2026-11-26 20:34:15'),
(64, 22, 'https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Apple+Silicone+Case+MagSafe+iPhone+-+B%E1%BA%A3o+v%E1%BB%87', 'Bảo vệ máy trước va chạm', 'Bảo vệ', 'Hạn chế trầy xước và va đập trong quá trình sử dụng hằng ngày.', 1, '2026-11-26 20:34:15'),
(65, 22, 'https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Apple+Silicone+Case+MagSafe+iPhone+-+V%E1%BB%ABa+v%E1%BA%B7n', 'Khoét chính xác từng chi tiết', 'Vừa vặn', 'Cổng sạc, nút bấm và camera được tính toán vị trí chính xác.', 2, '2026-11-26 20:34:15'),
(66, 22, 'https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Apple+Silicone+Case+MagSafe+iPhone+-+Th%E1%BA%A9m+m%E1%BB%B9', 'Giữ vẻ đẹp nguyên bản', 'Thẩm mỹ', 'Mỏng nhẹ, không làm cồng kềnh máy khi cầm trên tay.', 3, '2026-11-26 20:34:15'),
(67, 23, 'https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Samsung+Silicone+Case+Galaxy+S24+U+-+B%E1%BA%A3o+v%E1%BB%87', 'Bảo vệ máy trước va chạm', 'Bảo vệ', 'Hạn chế trầy xước và va đập trong quá trình sử dụng hằng ngày.', 1, '2026-11-26 20:34:15'),
(68, 23, 'https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Samsung+Silicone+Case+Galaxy+S24+U+-+V%E1%BB%ABa+v%E1%BA%B7n', 'Khoét chính xác từng chi tiết', 'Vừa vặn', 'Cổng sạc, nút bấm và camera được tính toán vị trí chính xác.', 2, '2026-11-26 20:34:15'),
(69, 23, 'https://placehold.co/800x600/111827/ffffff/png?text=%E1%BB%90p+l%C6%B0ng+Samsung+Silicone+Case+Galaxy+S24+U+-+Th%E1%BA%A9m+m%E1%BB%B9', 'Giữ vẻ đẹp nguyên bản', 'Thẩm mỹ', 'Mỏng nhẹ, không làm cồng kềnh máy khi cầm trên tay.', 3, '2026-11-26 20:34:15'),
(76, 26, 'https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Xiaomi+20.000mAh+22.5W+-+Dung+l%C6%B0%E1%BB%A3ng', 'Dung lượng đủ dùng cả ngày', 'Dung lượng', 'Sạc đầy điện thoại nhiều lần khi đi xa, không lo hết pin.', 1, '2026-11-26 20:34:15'),
(77, 26, 'https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Xiaomi+20.000mAh+22.5W+-+S%E1%BA%A1c+nhanh', 'Công suất sạc nhanh', 'Sạc nhanh', 'Hỗ trợ sạc nhanh cho điện thoại, máy tính bảng và phụ kiện.', 2, '2026-11-26 20:34:15'),
(78, 26, 'https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Xiaomi+20.000mAh+22.5W+-+An+to%C3%A0n', 'Nhiều lớp bảo vệ', 'An toàn', 'Bảo vệ quá nhiệt, quá dòng, ngắn mạch, sạc an toàn cho thiết bị.', 3, '2026-11-26 20:34:15'),
(79, 27, 'https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Baseus+Blade+20.000mAh+10+-+Dung+l%C6%B0%E1%BB%A3ng', 'Dung lượng đủ dùng cả ngày', 'Dung lượng', 'Sạc đầy điện thoại nhiều lần khi đi xa, không lo hết pin.', 1, '2026-11-26 20:34:16'),
(80, 27, 'https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Baseus+Blade+20.000mAh+10+-+S%E1%BA%A1c+nhanh', 'Công suất sạc nhanh', 'Sạc nhanh', 'Hỗ trợ sạc nhanh cho điện thoại, máy tính bảng và phụ kiện.', 2, '2026-11-26 20:34:16'),
(81, 27, 'https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Baseus+Blade+20.000mAh+10+-+An+to%C3%A0n', 'Nhiều lớp bảo vệ', 'An toàn', 'Bảo vệ quá nhiệt, quá dòng, ngắn mạch, sạc an toàn cho thiết bị.', 3, '2026-11-26 20:34:16'),
(82, 28, 'https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Anker+737+24.000mAh+140W+-+Dung+l%C6%B0%E1%BB%A3ng', 'Dung lượng đủ dùng cả ngày', 'Dung lượng', 'Sạc đầy điện thoại nhiều lần khi đi xa, không lo hết pin.', 1, '2026-11-26 20:34:16'),
(83, 28, 'https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Anker+737+24.000mAh+140W+-+S%E1%BA%A1c+nhanh', 'Công suất sạc nhanh', 'Sạc nhanh', 'Hỗ trợ sạc nhanh cho điện thoại, máy tính bảng và phụ kiện.', 2, '2026-11-26 20:34:16'),
(84, 28, 'https://placehold.co/800x600/111827/ffffff/png?text=Pin+s%E1%BA%A1c+d%E1%BB%B1+ph%C3%B2ng+Anker+737+24.000mAh+140W+-+An+to%C3%A0n', 'Nhiều lớp bảo vệ', 'An toàn', 'Bảo vệ quá nhiệt, quá dòng, ngắn mạch, sạc an toàn cho thiết bị.', 3, '2026-11-26 20:34:16');

-- -------------------------------------------------------------
-- Dữ liệu mẫu bảng `product_colors` (32 bản ghi)
-- -------------------------------------------------------------
INSERT INTO `product_colors` (`id`, `product_id`, `color_name`, `color_image`, `quantity`) VALUES
(1, 1, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=iPhone+%C4%90en', 20),
(2, 1, 'Hồng', 'https://placehold.co/600x600/db2777/ffffff/png?text=iPhone+H%E1%BB%93ng', 20),
(3, 1, 'Xanh', 'https://placehold.co/600x600/1d4ed8/ffffff/png?text=iPhone+Xanh', 20),
(4, 2, 'Xanh Navy', 'https://placehold.co/600x600/1d4ed8/ffffff/png?text=Samsung+Xanh+Navy', 35),
(5, 2, 'Tím Lilac', 'https://placehold.co/600x600/7c3aed/ffffff/png?text=Samsung+T%C3%ADm+Lilac', 35),
(6, 3, 'Đen Midnight', 'https://placehold.co/600x600/111827/ffffff/png?text=Xiaomi+%C4%90en+Midnight', 26),
(7, 3, 'Tím Aurora', 'https://placehold.co/600x600/7c3aed/ffffff/png?text=Xiaomi+T%C3%ADm+Aurora', 26),
(8, 3, 'Xanh Ocean', 'https://placehold.co/600x600/1d4ed8/ffffff/png?text=Xiaomi+Xanh+Ocean', 26),
(13, 6, 'Trắng', 'https://placehold.co/600x600/e5e7eb/ffffff/png?text=Tai+Tr%E1%BA%AFng', 60),
(14, 7, 'Bạc', 'https://placehold.co/600x600/9ca3af/ffffff/png?text=Tai+B%E1%BA%A1c', 25),
(15, 7, 'Trắng', 'https://placehold.co/600x600/e5e7eb/ffffff/png?text=Tai+Tr%E1%BA%AFng', 25),
(16, 8, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=Tai+%C4%90en', 22),
(17, 8, 'Bạc', 'https://placehold.co/600x600/9ca3af/ffffff/png?text=Tai+B%E1%BA%A1c', 22),
(22, 11, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=Tai+%C4%90en', 100),
(23, 12, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=Tai+%C4%90en', 40),
(24, 12, 'Trắng', 'https://placehold.co/600x600/e5e7eb/ffffff/png?text=Tai+Tr%E1%BA%AFng', 40),
(25, 12, 'Xanh', 'https://placehold.co/600x600/1d4ed8/ffffff/png?text=Tai+Xanh', 40),
(26, 13, 'Bạc', 'https://placehold.co/600x600/9ca3af/ffffff/png?text=Tai+B%E1%BA%A1c', 100),
(31, 16, 'Trắng', 'https://placehold.co/600x600/e5e7eb/ffffff/png?text=C%E1%BB%A7+Tr%E1%BA%AFng', 150),
(32, 17, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=C%E1%BB%A7+%C4%90en', 75),
(33, 17, 'Trắng', 'https://placehold.co/600x600/e5e7eb/ffffff/png?text=C%E1%BB%A7+Tr%E1%BA%AFng', 75),
(34, 18, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=C%E1%BB%A7+%C4%90en', 100),
(38, 21, 'Trong suốt', 'https://placehold.co/600x600/d1d5db/ffffff/png?text=K%C3%ADnh+Trong+su%E1%BB%91t', 150),
(39, 22, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=%E1%BB%90p+%C4%90en', 30),
(40, 22, 'Hồng', 'https://placehold.co/600x600/db2777/ffffff/png?text=%E1%BB%90p+H%E1%BB%93ng', 30),
(41, 23, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=%E1%BB%90p+%C4%90en', 35),
(42, 23, 'Tím', 'https://placehold.co/600x600/7c3aed/ffffff/png?text=%E1%BB%90p+T%C3%ADm', 35),
(46, 26, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=Pin+%C4%90en', 50),
(47, 26, 'Bạc', 'https://placehold.co/600x600/9ca3af/ffffff/png?text=Pin+B%E1%BA%A1c', 50),
(48, 27, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=Pin+%C4%90en', 30),
(49, 27, 'Xám', 'https://placehold.co/600x600/6b7280/ffffff/png?text=Pin+X%C3%A1m', 30),
(50, 28, 'Đen', 'https://placehold.co/600x600/111827/ffffff/png?text=Pin+%C4%90en', 40);

SET FOREIGN_KEY_CHECKS = 1;

-- ==============================================================
-- HOÀN TẤT KHỞI TẠO CƠ SỞ DỮ LIỆU ĐẦY ĐỦ 100% (ĐÃ BỎ SẢN PHẨM MẪU)!
-- SẴN SÀNG ĐỂ NGƯỜI DÙNG TỰ THÊM SẢN PHẨM VÀ NỘP BÀI!
-- ==============================================================
