/**
 * NEXVORA Real-Time Engine (nexvora-realtime.js)
 * Cung cấp khả năng cập nhật tức thì toàn bộ trang web (Client & Admin)
 * Không cần người dùng hoặc quản trị viên phải nhấn tải lại trang.
 */
(function() {
    'use strict';

    if (window.NexvoraRealtime) return;

    class RealtimeClient {
        constructor() {
            this.baseUrl = window.NEXVORA_BASE_URL || (window.location.origin + window.location.pathname.replace(/\/[^\/]*$/, '/'));
            this.scope = window.NEXVORA_IS_ADMIN ? 'admin' : 'client';
            this.lastEventId = 0;
            this.pollInterval = 2000; // 2 giây
            this.timer = null;
            this.isPolling = false;
            this.handlers = new Map();
            this.notificationQueue = [];
            
            this.init();
        }

        async init() {
            // Lấy event ID mới nhất để không bắn lại các sự kiện quá khứ
            try {
                const res = await fetch(`${this.baseUrl}index.php?url=api/realtime/init`);
                if (res.ok) {
                    const data = await res.json();
                    if (data.success && data.latest_event_id !== undefined) {
                        this.lastEventId = data.latest_event_id;
                    }
                }
            } catch (e) {
                // Fallback nếu server chưa phản hồi
            }

            this.registerDefaultHandlers();
            this.start();
        }

        start() {
            if (this.timer) clearInterval(this.timer);
            this.timer = setInterval(() => this.poll(), this.pollInterval);
        }

        stop() {
            if (this.timer) {
                clearInterval(this.timer);
                this.timer = null;
            }
        }

        on(eventType, callback) {
            if (!this.handlers.has(eventType)) {
                this.handlers.set(eventType, []);
            }
            this.handlers.get(eventType).push(callback);
        }

        emit(event) {
            const type = event.event_type;
            if (this.handlers.has(type)) {
                this.handlers.get(type).forEach(cb => {
                    try { cb(event); } catch (err) { console.error('Realtime callback error:', err); }
                });
            }
            if (this.handlers.has('*')) {
                this.handlers.get('*').forEach(cb => {
                    try { cb(event); } catch (err) { console.error('Realtime callback error:', err); }
                });
            }
        }

        async poll() {
            if (this.isPolling) return;
            this.isPolling = true;

            try {
                const url = `${this.baseUrl}index.php?url=api/realtime/poll&last_id=${this.lastEventId}&scope=${this.scope}&t=${Date.now()}`;
                const res = await fetch(url);
                if (res.ok) {
                    const data = await res.json();
                    if (data.success) {
                        if (data.latest_event_id && data.latest_event_id > this.lastEventId) {
                            this.lastEventId = data.latest_event_id;
                        }
                        if (Array.isArray(data.events) && data.events.length > 0) {
                            data.events.forEach(evt => this.handleEvent(evt));
                        }
                    }
                }
            } catch (e) {
                // Silent network retry
            } finally {
                this.isPolling = false;
            }
        }

        handleEvent(event) {
            // 1. Kích hoạt custom handlers
            this.emit(event);

            // 2. Xử lý thông báo Toast tức thì
            this.showToast(event);

            // 3. Xử lý cập nhật DOM tương ứng
            this.handleDomUpdates(event);
        }

        showToast(event) {
            const title = event.title || 'Thông báo hệ thống';
            const msg = event.message || '';
            
            // Nếu có SweetAlert2
            if (typeof Swal !== 'undefined') {
                let icon = 'info';
                if (event.event_type.includes('created') || event.event_type.includes('restored') || event.event_type.includes('completed')) {
                    icon = 'success';
                } else if (event.event_type.includes('cancelled') || event.event_type.includes('deleted')) {
                    icon = 'warning';
                }

                Swal.fire({
                    toast: true,
                    position: 'top-end',
                    icon: icon,
                    title: title,
                    text: msg,
                    showConfirmButton: false,
                    timer: 4000,
                    timerProgressBar: true,
                    background: '#0f172a',
                    color: '#f8fafc',
                    didOpen: (toast) => {
                        toast.addEventListener('mouseenter', Swal.stopTimer);
                        toast.addEventListener('mouseleave', Swal.resumeTimer);
                    }
                });
            }
        }

        handleDomUpdates(event) {
            const type = event.event_type;
            const payload = event.payload || {};

            // --- PHÍA CLIENT ---
            if (this.scope === 'client') {
                // Khi sản phẩm bị xóa hoặc hết hàng: Ẩn card tức thì
                if (type === 'product_deleted' || (type === 'product_updated' && payload.quantity <= 0)) {
                    const pid = String(event.entity_id || payload.product_id);
                    document.querySelectorAll(`[data-product-card][data-product-id="${pid}"]`).forEach(card => {
                        card.style.transition = 'all 0.5s ease';
                        card.style.opacity = '0';
                        card.style.transform = 'scale(0.85)';
                        setTimeout(() => card.remove(), 500);
                    });
                }

                // Khi cập nhật trạng thái đơn hàng của người dùng đang đăng nhập
                if (type === 'order_status_updated') {
                    const currentUserId = window.NEXVORA_CURRENT_USER_ID;
                    if (currentUserId && payload.user_id && String(currentUserId) === String(payload.user_id)) {
                        const orderRow = document.querySelector(`[data-order-row="${payload.order_code || payload.order_id}"]`);
                        if (orderRow) {
                            const badge = orderRow.querySelector('.order-status-badge');
                            if (badge) {
                                badge.textContent = payload.new_status;
                            }
                        }
                    }
                }
            }

            // --- PHÍA ADMIN ---
            if (this.scope === 'admin') {
                // Khi có đơn hàng mới
                if (type === 'order_created') {
                    // Nếu đang ở trang danh sách đơn hàng (admin/orders), tự động chèn hoặc cập nhật
                    const ordersTable = document.querySelector('#ordersTableBody, .orders-table-body');
                    if (ordersTable) {
                        // Tự động tải lại phần bảng hoặc báo hiệu để Admin bấm xem
                        const flashRow = document.createElement('tr');
                        flashRow.className = 'bg-cyan-950/40 border-b border-cyan-800/60 animate-pulse text-xs';
                        flashRow.innerHTML = `
                            <td class="py-3 px-4 font-mono font-bold text-cyan-300">#${payload.order_code || 'MỚI'}</td>
                            <td class="py-3 px-4 text-white font-semibold">${payload.customer_name || 'Khách hàng'}</td>
                            <td class="py-3 px-4 text-emerald-400 font-bold">${Number(payload.final_amount || 0).toLocaleString('vi-VN')}đ</td>
                            <td class="py-3 px-4"><span class="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-500/20 text-amber-300 border border-amber-500/40">Vừa đặt (Chờ duyệt)</span></td>
                            <td class="py-3 px-4 text-right">
                                <a href="${this.baseUrl}index.php?url=admin/orders" class="text-xs text-cyan-400 hover:underline font-bold">Xem ngay</a>
                            </td>
                        `;
                        ordersTable.insertBefore(flashRow, ordersTable.firstChild);
                    }

                    // Tăng số lượng badge đơn hàng ở Admin Navbar / Sidebar nếu có
                    const badge = document.querySelector('#pendingOrdersBadge, .pending-orders-badge');
                    if (badge) {
                        const cur = parseInt(badge.textContent) || 0;
                        badge.textContent = cur + 1;
                        badge.classList.remove('hidden');
                    }
                }

                // Khi sản phẩm thay đổi số lượng / hết hàng
                if (type === 'product_updated' || type === 'product_created') {
                    const row = document.querySelector(`[data-product-row="${event.entity_id}"]`);
                    if (row && payload.quantity !== undefined) {
                        const qtyCell = row.querySelector('.product-qty-cell');
                        if (qtyCell) {
                            qtyCell.textContent = payload.quantity;
                        }
                    }
                }
            }
        }

        registerDefaultHandlers() {
            // Có thể mở rộng thêm custom hooks ở đây
        }
    }

    // Gắn instance toàn cục
    window.NexvoraRealtime = new RealtimeClient();
})();
