 # Mapping Mobile ↔ Backend APIs & Missing Endpoint Specs

 Ngày: 2026-05-26

 Tài liệu này tổng hợp mapping giữa các pages/features trên mobile (Flutter) với REST API backend hiện có, chỉ ra endpoint nào đã có sẵn và endpoint nào còn thiếu. Phần "Missing endpoints" cung cấp spec chi tiết (method, path, auth, body, sample response, priority, notes) để bạn chuyển cho backend team triển khai.

 ## Tóm tắt nhanh
 - Backend hiện có nhiều endpoint (Auth, Users, Health, Lockers cơ bản, Bookings, Packages, Orders, Payments, Admin). Tuy nhiên mobile yêu cầu thêm một số endpoint để trải nghiệm đầy đủ: locker map, open locker, locker settings, QR-scan, scan history, notifications.

 ## Ghi chú cách đọc
 - "Exists" nghĩa là đã tìm thấy controller/action tương ứng trong `backend/src/Locker.Backend/Controllers`.
 - "Missing" nghĩa là không tìm thấy endpoint tương ứng trong backend hiện tại và mobile sẽ gọi dẫn đến lỗi runtime.

## Bảng theo folder mobile

### 1) Folder đang gọi backend trực tiếp

| Folder | Mobile repo / page chính | API backend đã có | API còn thiếu | Trạng thái |
| --- | --- | --- | --- | --- |
| auth | `auth_repository.dart` / login screen | `POST /api/auth/login`, `POST /api/auth/refresh`, `POST /api/auth/logout` | Không thiếu cho luồng hiện tại; `register`, `verify-email`, `forgot/reset password` đã có ở backend nhưng chưa được repo này dùng | Đã nối một phần |
| profile | `profile_repository.dart` | `GET /api/users/me`, `POST /api/auth/logout` | Không thiếu cho luồng hiện tại | Đã nối |
| settings | `settings_repository.dart` | `GET /api/users/me`, `POST /api/auth/logout` | Nếu sau này thêm đổi mật khẩu thì backend đã có `POST /api/users/me/change-password` | Đã nối một phần |
| home | `home_repository.dart` | `GET /api/bookings/my`, `GET /api/lockers/available` | Không thiếu cho luồng hiện tại | Đã nối |
| locker | `locker_repository.dart` | `GET /api/lockers`, `GET /api/lockers/available` | Không thiếu cho luồng hiện tại | Đã nối |
| locker_detail | `locker_detail_repository.dart` | `GET /api/lockers/{id}` | `POST /api/lockers/{id}/open`, `PATCH /api/lockers/{id}/settings` | Thiếu 2 endpoint |
| locker_map | `locker_map_repository.dart` | Không có endpoint khớp trực tiếp | `GET /api/lockers/map`, `POST /api/lockers/{id}/open` | Thiếu 2 endpoint |
| notifications | `notification_repository.dart` / notification screen | Không có endpoint khớp trực tiếp | `GET /api/notifications/my`, `POST /api/notifications/{id}/mark-as-read`, `POST /api/notifications/mark-all-as-read` | Thiếu toàn bộ |
| qr_scanner | `qr_scanner_repository.dart` | Không có endpoint khớp trực tiếp | `POST /api/lockers/qr-scan`, `GET /api/lockers/scan-history` | Thiếu toàn bộ |

### 2) Folder hiện mock/local, chưa bám backend thật

| Folder | Mobile repo / page chính | API backend đã có | API còn thiếu | Trạng thái |
| --- ---| --- | --- | --- | --- |
| delivery | `delivery_repository.dart` / send_receive screen | Backend chưa có endpoint khớp trực tiếp | Cần thiết kế mới nếu muốn thật: danh sách size, tạo gửi hàng, xác nhận mã nhận hàng, luồng overdue | Đang mock |
| food_order | `food_order_repository.dart` | Backend chưa có endpoint khớp trực tiếp | Nếu muốn dùng thật cần API riêng cho nhà hàng/menu | Đang mock |
| orders | `orders_repository.dart` | Backend có `orders/*` nhưng mobile chưa gọi | Không thiếu cho code hiện tại vì đang fake data | Đang mock |
| payment_failed | `payment_failed_repository.dart` | Backend có `payments/*` nhưng repo này không gọi | Không thiếu cho code hiện tại | Đang mock |
| payment_success | `payment_success_repository.dart` | Backend có `payments/*` nhưng repo này không gọi | Không thiếu cho code hiện tại | Đang mock |
| personal_info | `personal_info_repository.dart` / personal info page | Backend đã có `GET /api/users/me`, `PUT /api/users/me`, `POST /api/users/me/change-password` | Chưa thiếu API, nhưng repo hiện tại đang mock dữ liệu hồ sơ | Đang mock |
| locker_overdue_penalty | `locker_overdue_repository.dart` | Backend chưa có endpoint khớp trực tiếp | Cần API riêng nếu muốn đồng bộ tiền phạt/quá hạn | Đang mock |
| menu | `menu_repository.dart` | Backend chưa có endpoint khớp trực tiếp | Cần API menu/restaurant nếu muốn thật | Đang mock |
| photo_confirmation | `photo_confirmation_repository.dart` | Backend chưa có endpoint khớp trực tiếp | Cần API lưu ảnh/xác nhận ảnh nếu muốn thật | Đang mock |
| send_receive | `send_receive_repository.dart` | Backend có thể map sang `bookings/*` hoặc `orders/*`, nhưng repo hiện chưa gọi | Chưa thiếu cho code hiện tại vì đang fake toàn bộ | Đang mock |
| send_success | `send_success_repository.dart` | Backend có `orders/*` / `payments/*` nhưng repo này không gọi | Không thiếu cho code hiện tại | Đang mock |
| security_privacy | `security_privacy_repository.dart` | Backend chưa có endpoint khớp trực tiếp | Nếu muốn đồng bộ bật/tắt FaceID/2FA/login alert thì cần API settings riêng | Đang mock |
| sign_up | `sign_up_repository.dart` | Backend đã có `POST /api/auth/register` | Repo hiện chưa dùng backend thật, nên chưa thiếu API | Đang mock |
| wallet | `wallet_repository.dart` | Backend có `payments/*` nhưng repo này không gọi | Không thiếu cho code hiện tại | Đang mock |

 ---

 ## Mapping theo feature / page (mobile → API)

 1) Auth / Login
 - POST /api/auth/login — Exists (AuthController)
 - POST /api/auth/refresh — Exists
 - POST /api/auth/logout — Exists

 2) Profile / Settings (personal info page)
 - GET /api/users/me — Exists
 - PUT /api/users/me — Exists
 - POST /api/users/me/change-password — Exists

 3) Lockers list / Home
 - GET /api/lockers — Exists
 - GET /api/lockers/available — Exists

 4) Locker Map (map view showing slots per locker) — mobile expects map data
 - GET /api/lockers/map — Missing
   - Mobile: `LockerMapRepository.getLockerSlots` và UI map đòi dữ liệu slot-level

 5) Locker Detail / Open Locker
 - GET /api/lockers/{id} — Exists
 - POST /api/lockers/{id}/open — Missing
   - Mobile calls open action from map and detail pages.

 6) Locker Settings (auto-lock, intrusion alert) — toggles from mobile
 - PATCH /api/lockers/{id}/settings — Missing

 7) QR Scanner / Scan history
 - POST /api/lockers/qr-scan — Missing (QR validation)
 - GET /api/lockers/scan-history — Missing

 8) Bookings / Home
 - GET /api/bookings/my?status=... — Exists
 - POST /api/bookings — Exists

 9) Orders & Wallet
 - Mobile currently uses mocked/stubbed data for Orders and Wallet. Backend has orders/payments endpoints but some flows are not yet wired by mobile. (No immediate blocking endpoints beyond the locker/notification set.)

 10) Notifications
 - GET /api/notifications/my — Missing
 - POST /api/notifications/{id}/mark-as-read — Missing
 - POST /api/notifications/mark-all-as-read — Missing

 ---

 ## Priority list (tác động tới UX)
 1. High: GET /api/lockers/map, POST /api/lockers/{id}/open, POST /api/lockers/qr-scan — cần để map, mở tủ, QR flow hoạt động.
 2. Medium: PATCH /api/lockers/{id}/settings, GET /api/lockers/scan-history — cài đặt tủ và lịch sử quét.
 3. Low: Notifications endpoints — không ngăn mobile chạy nhưng làm thiếu trải nghiệm thông báo.

 ---

 ## Missing endpoints — Specs đề xuất

 Tất cả endpoint yêu cầu xác thực Bearer token (Authorization: Bearer <access_token>) trừ khi ghi chú khác.

 1) GET /api/lockers/map
 - Mục đích: Trả về sơ đồ slot đầy đủ cho tất cả locker (dùng cho view bản đồ / grid). Mobile cần biết mỗi slot đang ở trạng thái nào (Available, Occupied, Reserved, Fault), kích thước, index, vị trí trên map nếu có.
 - Method: GET
 - Auth: Required
 - Query: optional: ?nearbyOnly=true|false
 - Response (200):

 ```json
 {
   "lockers": [
     {
       "id": "guid-or-int",
       "name": "Locker A",
       "location": { "lat": 10.0, "lng": 106.0 },
       "slots": [
         { "index": 0, "size": "Small|Medium|Large", "status": "Available|Occupied|Reserved|Fault", "bookingId": null },
         { "index": 1, "size": "Medium", "status": "Occupied", "bookingId": "bkg-123" }
       ]
     }
   ]
 }
 ```

 - Notes: Implementation có thể aggregate từ dữ liệu locker/slot. Include bookingId khi slot reserved/occupied.

 2) POST /api/lockers/{lockerId}/open
 - Mục đích: Yêu cầu server mở cửa cho một locker (khi user đủ quyền/booking). Backend sẽ kiểm tra quyền (user owns booking or staff), tạo action/command và gửi đến firmware/gateway (MQTT/command queue) hoặc update DB, rồi trả trạng thái.
 - Method: POST
 - Auth: Required
 - Path params: lockerId
 - Body (application/json):

 ```json
 {
   "slotIndex": 3,
   "reason": "user_open"
 }
 ```

 - Response (200):

 ```json
 { "success": true, "message": "Open command queued", "commandId": "cmd-123" }
 ```

 - Response (403): user not authorized
 - Response (404): locker or slot not found

 - Notes: Implementation must bridge to device layer (send MQTT or call firmware gateway). Nếu cần phản hồi real-time, support async status polling.

 3) PATCH /api/lockers/{lockerId}/settings
 - Mục đích: Cập nhật cài đặt locker (isAutoLockEnabled, isIntrusionAlertEnabled, friendlyName...).
 - Method: PATCH
 - Auth: Required (Admin or locker owner theo policy)
 - Body (application/json) — partial update:

 ```json
 {
   "isAutoLockEnabled": true,
   "isIntrusionAlertEnabled": false,
   "displayName": "Locker A - Lobby"
 }
 ```

 - Response (200): updated locker DTO

 4) POST /api/lockers/qr-scan
 - Mục đích: Mobile gửi payload QR (text) để backend xác thực và trả về hành động (ví dụ: open, show_booking, link_to_payment).
 - Method: POST
 - Auth: Required
 - Body:

 ```json
 {
   "qrText": "...",
   "location": { "lat": 10.0, "lng": 106.0 }
 }
 ```

 - Response (200):

 ```json
 {
   "action": "open",
   "bookingId": "bkg-123",
   "requiresPin": true,
   "message": "valid QR for booking"
 }
 ```

 - Response (400/404): invalid/expired QR

 5) GET /api/lockers/scan-history
 - Mục đích: Trả về lịch sử các mã QR mà user đã quét (history).
 - Method: GET
 - Auth: Required
 - Query: ?limit=20&offset=0
 - Response (200):

 ```json
 {
   "scans": [
     { "id":"s1","qrText":"...","result":"open","bookingId":"b1","scannedAt":"2026-05-01T12:00:00Z" }
   ]
 }
 ```

 6) Notifications endpoints
 - a) GET /api/notifications/my
   - Method: GET
   - Auth: Required
   - Response: list of notifications (id, title, body, createdAt, isRead, metadata)

 ```json
 {
   "notifications": [
     { "id":"n1","title":"Your package arrived","body":"...","isRead":false,"createdAt":"...","data":{}} 
   ]
 }
 ```

 - b) POST /api/notifications/{id}/mark-as-read
   - Method: POST
   - Auth: Required
   - Response: 200 { "success": true }

 - c) POST /api/notifications/mark-all-as-read
   - Method: POST
   - Auth: Required
   - Response: 200 { "success": true }

 Notes: Notifications có thể lưu vào DB; cho MVP implement DB-backed per-user notifications.

 ---

 ## Implementation notes & suggestions cho backend team

 - Authentication: mọi endpoint mới yêu cầu Bearer token. Reuse existing auth middleware.
 - Error codes: dùng 200 cho success, 4xx cho client errors, 5xx cho server errors. Trả structured error: { "code": "InvalidQr", "message": "..." }.
 - Telemetry/commands: POST /api/lockers/{id}/open nên enqueue command vào một queue (DB table Commands) và publish tới broker (MQTT/Redis) để gateway/firmware xử lý. Trả về commandId để client/tracker polling trạng thái nếu cần.
 - Concurrency: khi mở tủ, backend cần kiểm tra slot state/reservation để tránh race condition.
 - Security: ensure only authorized users (booking owner, shipper, or admin) can open lockers.

 ---

 ## Đề xuất hành động giai đoạn ngắn
 1. Triển khai nhanh các stub endpoint (trả sample JSON) để mobile developer có thể test end-to-end.
 2. Triển khai thực tế: thực hiện business logic + publish command tới device gateway.
 3. Bổ sung tests + Swagger docs cho các endpoint mới.

 ---

 Nếu bạn muốn, tôi có thể:
 - A) Tạo pull request (C#) chứa các controller stub trong `backend/src/Locker.Backend/Controllers` để backend team review.
 - B) Sinh file CSV/Excel mapping page → endpoint để gửi cho PM/backend.
 - C) Thêm các mẫu response/DTO C# đề xuất (classes) để backend dev dùng ngay.

 Chọn A, B, hoặc C hoặc nói rõ bạn muốn bắt đầu bằng gì.
