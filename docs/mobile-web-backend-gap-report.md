# 📊 Báo cáo rà soát Mobile vs Web vs Backend — Locker

> **Ngày tạo**: 2026-08-15
> **Phạm vi**: `d:\GitHub\Locker` (backend, web, mobile)
> **Loại**: Read-only inventory + cross-reference gap analysis

---

## 1. Tổng quan dự án

| Tiêu chí | Backend | Web | Mobile |
|---|---|---|---|
| Stack | ASP.NET Core (.NET 10) + MongoDB + MediatR CQRS + JWT | React 18 + TS + Vite + react-router v7 | Flutter (Dart 3.10) + Bloc + Dio + Firebase |
| Độ phủ domain | **17 feature folders, 110+ CQRS, 21 controllers** | 17 features, 35 routes | 30 features, 33 routes |
| Auth | JWT + refresh + Firebase Google + Resend email | Có | Có (Google chưa wire) |
| Realtime | SignalR `/hubs/notifications` (2 event) | Có SignalR subscribe | **Chưa thấy SignalR client** |
| Map provider | — | Google Maps (qua `MapView` button) | **Mapbox** Maps |
| DB | MongoDB (MongoDbCore Identity) | — | — |
| 3rd-party | SePay, VNPay, Firebase Admin, Resend | axios (không dùng), SignalR client | Firebase Core/Auth/Messaging, Mapbox, mobile_scanner, geolocator, url_launcher |

---

## 2. Routes / Screens inventory

### 2.1 Backend — 21 controllers

| Controller | Route prefix | Endpoints | Auth |
|---|---|---|---|
| `AuthController` | `api/auth` | 10 | Mixed (login/register/verify/forgot/reset/google = anonymous; logout = auth; rate-limit 10/min) |
| `UsersController` | `api/users` | 3 | Authenticated |
| `PackagesController` | `api/packages` | 5 | Mixed (GET anonymous; POST/PUT Admin) |
| `LockersController` | `api/lockers` | 13 | Mixed |
| `LockerEventsController` | `api/lockers/{id}` | 2 | Admin only |
| `BookingsController` | `api/bookings` | 7 | Authenticated |
| `OrdersController` | `api/orders` | 11 | Mixed |
| `PaymentsController` | `api/payments` | 6 | Mixed |
| `WalletController` | `api/wallet` | 12 | Mixed (top-up webhook endpoints anonymous) |
| `NotificationsController` | `api/notifications` | 4 | Authenticated |
| `DeviceTokensController` | `api/device-tokens` | 2 | Authenticated |
| `SendReceiveOrdersController` | `api/send-receive/orders` | 5 | Authenticated |
| `DeliveryController` | `api/delivery` | 4 | Mixed |
| `RestaurantsController` | `api/restaurants` | 3 | Authenticated |
| `FoodOrdersController` | `api/food-orders` | 3 | Authenticated |
| `FeedbacksController` | `api/feedbacks` | 3 | Mixed |
| `AdminFeedbacksController` | `api/admin/feedbacks` | 3 | Admin only |
| `AdminController` | `api/admin` | 7 | Admin only |
| `DashboardController` | `api/dashboard` | 2 | Mixed (user/shipper) |
| `HealthController` | `api/health` | 1 | Anonymous |
| `BaseApiController` | — | 0 | abstract helper |

### 2.2 Web — 35 routes

```
PUBLIC
  /                                  HomePage
  /login                             LoginPage
  /register                          RegisterPage
  /verify-email                      VerifyEmailPage
  /verify-email/result               EmailVerificationResultPage
  /forgot-password                   ForgotPasswordPage
  /reset-password                    ResetPasswordPage
  /track/:trackingCode               TrackDeliveryPage

AUTHENTICATED (any role)
  /profile                           ProfilePage
  /settings                          SettingsPage
  /wallet                            WalletPage
  /lockers                           LockersPage
  /lockers/:id                       LockerDetailPage

ADMIN ONLY
  /dashboard                         AdminDashboardPage
  /users                             AdminUsersPage
  /feedbacks                         AdminFeedbackPage

USER ONLY
  /my-dashboard                      DashboardPage
  /dashboard                         DashboardPage (alias)
  /packages                          PackagesPage
  /orders                            OrdersPage
  /orders/new                        CreateOrderPage
  /orders/:id                        OrderDetailPage
  /bookings                          BookingsPage
  /bookings/:id                      BookingDetailPage
  /send-receive                      SendReceivePage
  /send-receive/new                  CreateSendReceivePage
  /send-receive/:id                  SendReceiveDetailPage
  /food                              RestaurantsPage
  /food/checkout                     CheckoutFoodPage
  /food/orders                       FoodOrdersPage
  /food/orders/:id                   FoodOrderDetailPage
  /food/:id                          RestaurantDetailPage
  /payment/:orderId                  PaymentPage

SHIPPER ONLY
  /shipper/tasks                     DeliveryTasksPage
  /shipper/tasks/:id                 DeliveryTaskDetailPage
  /shipper/delivery/new              CreateDeliveryPage
```

Note: `web/src/features/payments/pages/{Success,Cancel,Error}.tsx` exist but **not mounted** in `AppRoutes`.

### 2.3 Mobile — 33 routes

```
/login                  LoginPage
/sign-up                SignUpPage
/home                   HomePage
/profile                ProfilePage
/wallet                 WalletPage
/top-up                 TopUpPage (WalletCubit passed via arguments)
/orders                 OrdersPage
/send-receive           SendReceivePage (send_receive feature)
/delivery               SendReceivePage (delivery feature)
/payment                PaymentPage (with orderData arg)
/food-order             FoodOrderPage
/food-cart-payment      EBoxFoodCartPayment (FoodCartPaymentArgs)
/payment-success        PaymentSuccessPage (PaymentSuccessRequest arg)
/payment-failed         PaymentFailedPage (PaymentFailedRequest arg)
/send-success           SendSuccessPage (SendSuccessRequest arg)
/photo-confirmation     PhotoConfirmationPage (lockerId arg)
/menu                   MenuPage (restaurantId+restaurantName args)
/lockers                LockerScreen
/locker-map             LockerMapPage
/locker-detail          LockerDetailPage (lockerId arg)
/qr-scanner             QrScannerPage
/scan-history           ScanHistoryPage
/settings               SettingsPage
/feedback               FeedbackPage
/notifications          NotificationPage
/security-privacy       SecurityPrivacyPage
/personal-info          PersonalInfoPage
/change-password        ChangePasswordPage
/forgot-password        ForgotPasswordPage
/reset-password         ResetPasswordPage
```

Initial route: `/login`. Internal sub-steps (LockerSizePage, StorageDurationPage, OrderSummaryPage, PaymentSelectionPage) không đăng ký route name — push bằng `MaterialPageRoute`.

---

## 3. Bảng so sánh Endpoint ↔ Web ↔ Mobile

✅ = có UI gọi API · ⚠️ = có nhưng mock / partial · ❌ = thiếu hoàn toàn · — = không cần UI

| Backend Endpoint | Web có? | Mobile có? | Ghi chú |
|---|:---:|:---:|---|
| `POST /auth/login` | ✅ | ✅ | — |
| `POST /auth/register` | ✅ | ✅ | — |
| `POST /auth/forgot-password` | ✅ | ✅ | — |
| `POST /auth/reset-password` | ✅ | ✅ | — |
| `POST /auth/google` (Firebase) | ❌ | ❌ | **Web & Mobile đều chưa có UI Google login.** Mobile import `firebase_auth`+`google_sign_in` nhưng `signInWithGoogle()` throws `UnimplementedError` |
| `POST /auth/resend-verification` | ✅ | ✅ | — |
| `POST /auth/refresh`, `/auth/logout`, `/auth/logout-all` | ✅ (apiFetch) | ✅ (Dio interceptor) | — |
| `GET/PUT /users/me`, `/change-password` | ✅ | ✅ | — |
| `GET /lockers`, `GET /lockers/:id`, `/lockers/available`, `/lockers/map` | ✅ | ✅ | — |
| `POST /lockers/:id/open` | ❌ | ✅ | **Web THIẾU** nút mở locker |
| `GET /lockers/scan-history` | ❌ | ✅ | Mobile có `/scan-history`; **Web THIẾU** |
| `POST /lockers/qr-scan` | ❌ | ✅ | Mobile có `/qr-scanner`; **Web CHƯA có** QR scan |
| `PATCH /lockers/:id/settings` | ❌ | ✅ | Mobile có toggle Auto-lock / Intrusion; **Web CHƯA có** |
| `POST /lockers/:id/slots/:slotIndex/status`, `/open-event` (firmware) | ❌ | ❌ | Phục vụ firmware — không cần UI |
| `GET /lockers/:id/events`, `/slots/:idx/events` | ❌ | ❌ | Admin chưa làm trang event log cả 2 |
| `GET /dashboard/user`, `/dashboard/shipper` | ⚠️ (mock) | ❌ | **Web `DashboardPage` đang dùng `getMockUserDashboard` — chưa gọi API thật** |
| `GET /bookings/my`, `/bookings/:id` | ✅ | ❌ | **Mobile CHƯA có** màn booking list/detail |
| `POST /bookings`, `/set-pin`, `/verify-pin`, `/complete`, `/cancel` | ✅ | ❌ | **Mobile CHƯA có** booking flow (chỉ có orders thông qua send-receive) |
| `POST /orders/reserve`, `/confirm`, `/set-pin`, `/activate`, `/complete`, `/cancel`, `/extend` | ⚠️ (riêng lẻ) | ⚠️ | Web có `OrdersPage`/`OrderDetailPage`/`CreateOrderPage`. Mobile có `SendReceiveRepository.createSendReceiveOrder` (gọi `/orders/reserve`) nhưng **THIẾU activate/extend/cancel** |
| `GET /orders/availability/slots` | ❌ | ❌ | Cả 2 frontend chưa dùng — mobile đang loop thủ công |
| `POST /orders/:id/payment` (admin link) | ❌ | ❌ | Chỉ admin backend |
| `GET /payments/...` | ⚠️ (mock) | ❌ | **Web `PaymentPage` dùng mock QR**; mobile **CHƯA có** màn payment thật |
| `POST /payments/webhook` | ✅ | — | Backend-only |
| `GET /wallet/overview`, `/transactions`, `/balance` | ✅ | ✅ | — |
| `POST /wallet/top-up` | ✅ | ✅ | — |
| `POST /wallet/top-up/vnpay/init` + `/return` | ⚠️ | ❌ | Web có wallet nhưng chưa rõ gọi VNPay init. **Mobile CHƯA có** |
| `POST /wallet/top-up/sepay/init` + `/ipn` + `/return` + `/bank-notify` + `/cancel` | ⚠️ | ✅ (init) | Mobile gọi `/wallet/top-up/sepay/init`, **THIẾU** return/cancel handler. Web có thể chưa code SePay |
| `POST /wallet/transfer` | ❌ | ⚠️ (bug) | **Web CHƯA có**. Mobile `WalletRepository` build URL **bị double-base** — bug cần fix |
| `GET /delivery/requests/my`, `POST /delivery/requests`, `GET /delivery/requests/track/:code` | ✅ | ✅ (track public) | Mobile `DeliveryRepository.createSendRequest` tự loop slot 0-5 khi 400 — workaround |
| `POST /delivery/requests/submit-receive/:lockerId/:slotIndex` | ❌ | ❌ | Endpoint define nhưng cả 2 frontend **CHƯA gọi**; mobile `submitReceiveCode` đang mock |
| `GET /restaurants`, `/:id`, `/:id/menu` | ✅ | ⚠️ | Mobile `FoodOrderRepository` dùng hard-coded sample data; `restaurant_map` mới gọi API thật |
| `POST /food-orders`, `/my`, `/:id` | ✅ | ⚠️ | Mobile food order page chỉ là map — **CHƯA có flow order/cart thật** (chỉ có `EBoxFoodCartPayment` widget) |
| `GET /send-receive/orders/my`, `/:id`, các command confirm/complete | ✅ | ⚠️ | Mobile `send_receive` đặt qua `/orders/reserve`, **CHƯA gọi** `/send-receive/orders` |
| `GET /notifications/my`, `/mark-as-read`, `/mark-all-as-read`, `/register-device` | ✅ | ✅ | Mobile đăng ký FCM token qua `/notifications/register-device` |
| `GET /post/POST/PUT/DELETE /packages` (admin CRUD + public list) | ✅ (list) | ✅ (sizes) | OK |
| `POST/PUT/DELETE /packages` (admin) | ❌ | ❌ | **Admin CRUD package CHƯA có UI** cả web lẫn mobile |
| `GET /admin/users`, role/activate/deactivate | ✅ | ❌ | Mobile CHƯA có admin user management (đúng — mobile chỉ cho user) |
| `GET /admin/bookings`, `/admin/payments` | ❌ | ❌ | **Admin pages THIẾU** bookings & payments |
| `POST /admin/users` (admin create user) | ❌ | ❌ | Web `AdminUsersPage` có thể chưa có "Create user" form |
| `GET /feedbacks/me`, `PUT /feedbacks/me`, `GET /feedbacks/public` | ✅ | ✅ | — |
| `GET /admin/feedbacks`, `/visibility`, `/export` | ✅ | ❌ | Mobile CHƯA có admin feedback moderation (đúng) |
| `GET /device-tokens/my`, `DELETE /device-tokens/:id` | ❌ | ❌ | Cả 2 frontend dùng `/notifications/register-device` thay thế |
| `GET /admin/dashboard` endpoint | ❌ (UI mock) | — | Web đang mock; nên chuyển sang gọi `/dashboard/user` + `/dashboard/shipper` |

---

## 4. 🔴 Các trang/trường hợp Mobile THIẾU so với Backend

### 4.1 Module nghiệp vụ chính

| # | Mobile thiếu | Backend endpoint | Mức độ | Ghi chú |
|---|---|---|:---:|---|
| 1 | **Booking flow** (đặt locker theo giờ + PIN) | `/api/bookings/*` | 🔴 Critical | Backend đầy đủ 7 endpoints. Mobile chỉ có `send-receive` dùng `/orders/reserve`. Không có màn `/bookings`, `/bookings/:id`, verify PIN, complete/cancel |
| 2 | **Order lifecycle** (activate / extend / cancel / link payment) | `/api/orders/:id/{activate,extend,cancel,...}` | 🔴 Critical | Mobile chỉ reserve, không có extend time, activate, cancel — quan trọng cho UX lưu trữ dài hạn |
| 3 | **VNPay top-up flow** | `/api/wallet/top-up/vnpay/init`, `/return` | 🟠 High | VNPay chỉ có SePay là wired. Mobile mất luồng thanh toán VNPay |
| 4 | **Wallet transfer** | `/api/wallet/transfer` | 🟠 High | Mobile repo build URL sai (double-base), cần fix bug + add UI |
| 5 | **SePay return / cancel handler** | `/wallet/top-up/sepay/return`, `/cancel` | 🟡 Medium | Sau khi user trở về từ SePay, mobile không xử lý → user không biết kết quả |
| 6 | **Notifications realtime** (SignalR) | `/hubs/notifications` (event `NotificationReceived`) | 🟡 Medium | Backend đẩy push realtime nhưng mobile chỉ polling/list, không sub SignalR. Web đã có SignalR `NotificationsRealtime` |
| 7 | **Payment realtime** (SePay/VNPay status) | event `PaymentStatusChanged` | 🟡 Medium | Web `paymentRealtime.ts` đã sub. Mobile không có — top-up xong phải user manual refresh |
| 8 | **Google Sign-In** | `/api/auth/google` (Firebase ID token) | 🟠 High | `firebase_auth`+`google_sign_in` đã install nhưng `signInWithGoogle()` throws `UnimplementedError` — UI button cũng chưa thấy |
| 9 | **Email verify after register** | `/auth/resend-verification`, `/auth/verify-email` | 🟡 Medium | Mobile có `verify_email_screen.dart` nhưng không có route name; API call phải check trong `sign_up_repository` |
| 10 | **Order pin set/verify** | `/api/orders/:id/set-pin` | 🟡 Medium | Mobile không có UI set PIN riêng cho order (chỉ send-receive có PIN tự sinh) |
| 11 | **Public feedback reviews** | `GET /feedbacks/public?limit=6` | 🟢 Low | Mobile THIẾU màn hiển thị reviews (chỉ admin web có) |
| 12 | **Slot availability check** (real-time) | `GET /orders/availability/slots` | 🟡 Medium | Mobile tự loop slot 0-5 trong `DeliveryRepository` — workaround nên thay bằng API đúng |

### 4.2 Trang/màn hình cụ thể thiếu (so với Web)

| Trang trên Web | Mobile? | Đánh giá |
|---|:---:|---|
| `/track/:trackingCode` (public, no auth) | ❌ | 🔴 Thiếu — quan trọng cho khách nhận hàng track |
| `/home` (marketing landing) | ✅ (home mobile) | OK nhưng mobile chỉ là dashboard, không có hero/portal section như web |
| `/verify-email/result` | ❌ | 🟡 Nên có |
| `/packages` (storage packages list) | ❌ | 🟡 Chỉ dùng sizes trong send-receive, không có trang catalog |
| `/food/orders/:id` (food order detail) | ❌ | 🟠 Mobile chỉ có flow cart, không có list+detail |
| `/admin/dashboard`, `/admin/users`, `/admin/feedbacks` | ❌ | ✅ Đúng — mobile không phục vụ admin |
| `/shipper/tasks` | ❌ | 🟠 **Shipper flow mobile THIẾU HOÀN TOÀN** (backend có `/dashboard/shipper` + Delivery APIs) — đây là gap lớn nếu sản phẩm có vai trò Shipper |

### 4.3 Bug / code-smell Mobile cần sửa

| # | File | Vấn đề |
|---|---|---|
| 1 | `mobile/lib/features/wallet/data/wallet_repository.dart` | `transfer()` concat `apiBaseUrl + /wallet/transfer` → double base URL. Verify và fix. |
| 2 | `mobile/lib/features/auth/data/auth_repository.dart` | `signInWithGoogle()` throws `UnimplementedError` — stub chưa impl |
| 3 | `mobile/lib/features/delivery/data/delivery_repository.dart` | `createSendRequest` loops slots 0-5 manually khi 400 → nên dùng `GET /orders/availability/slots` |
| 4 | `mobile/lib/features/delivery/data/delivery_repository.dart` | `submitReceiveCode` đang mock, backend có endpoint `POST /delivery/requests/submit-receive/:lockerId/:slotIndex` |
| 5 | `mobile/lib/features/food_order/data/food_order_repository.dart` | Hard-coded sample data thay vì gọi `/restaurants` |
| 6 | `mobile/ios/Runner/SwiftUI/` | Còn file SwiftUI marketing template thừa (Builder.io leftover) — không ảnh hưởng runtime nhưng nên xoá |
| 7 | `mobile/lib/features/auth/presentation/verify_email_screen.dart` | Không có route name (chỉ dùng ModalRoute.arguments) — user không truy cập được |
| 8 | Token storage | Dùng `SharedPreferences` plaintext — nên upgrade sang `flutter_secure_storage` |

---

## 5. 🟢 Các trang Web THIẾU so với Backend

| # | Web thiếu | Backend endpoint | Mức độ |
|---|---|---|:---:|
| 1 | QR scanner UI | `POST /lockers/qr-scan` | 🟠 High — khách muốn mở locker qua QR không làm được trên web |
| 2 | Open locker từ xa (user) | `POST /lockers/{id}/open` | 🟠 High — web list locker nhưng không có nút mở |
| 3 | Locker scan history | `GET /lockers/scan-history` | 🟡 Medium |
| 4 | Locker settings (auto-lock/intrusion) | `PATCH /lockers/{id}/settings` | 🟡 Medium |
| 5 | Locker events log (admin) | `GET /lockers/{id}/events`, `/slots/:idx/events` | 🟡 Medium |
| 6 | Admin CRUD Packages | `POST/PUT/DELETE /packages` | 🟠 High — chỉ có list, không có create/edit package |
| 7 | Admin All Bookings | `GET /admin/bookings` | 🟠 High |
| 8 | Admin All Payments | `GET /admin/payments` | 🟠 High |
| 9 | Admin create user | `POST /admin/users` | 🟡 Medium |
| 10 | Order slot availability | `GET /orders/availability/slots` | 🟡 Medium |
| 11 | VNPay top-up flow | `/wallet/top-up/vnpay/init` + return | 🟠 High (nếu muốn support VNPay) |
| 12 | Wallet P2P transfer | `POST /wallet/transfer` | 🟡 Medium |
| 13 | SePay cancel top-up | `POST /wallet/top-up/sepay/cancel` | 🟢 Low |
| 14 | User Dashboard real data | `GET /dashboard/user` | 🟠 High — đang dùng mock |
| 15 | Shipper dashboard real data | `GET /dashboard/shipper` | 🟠 High — đang dùng mock |
| 16 | Mobile-friendly responsive check | — | UI mobile-style chưa được test đầy đủ trên web |
| 17 | Payments/Success/Cancel/Error pages mount | — | Files tồn tại nhưng **không đăng ký route** |

---

## 6. 📋 Ưu tiên đề xuất (theo impact)

### P0 — Làm ngay

1. **Mobile Booking flow** (`/bookings/my`, `/bookings/:id`) — backend sẵn, mobile còn trống
2. **Mobile Order lifecycle** (activate / extend / cancel) — backend đã có
3. **Mobile Shipper flow** — nếu nghiệp vụ có shipper thì đây là gap rất lớn
4. **Mobile Wallet Transfer fix bug** double-base URL
5. **Mobile SignalR subscribe** notifications & payment status
6. **Web dashboard real API** (đang dùng mock cho cả user + shipper)
7. **Web QR scan + open locker** (chức năng cốt lõi)
8. **Admin bookings + payments pages** trên web

### P1 — Quan trọng

9. Mobile Google Sign-In hoàn thiện (UI + Firebase wiring)
10. Mobile SePay return/cancel handler
11. Web Admin Package CRUD
12. Web Locker settings + event log
13. Mobile Delivery submit-receive (đang mock)
14. Mobile VNPay top-up flow
15. Mobile Food order list+detail
16. Web wallet P2P transfer
17. Web VNPay top-up

### P2 — Nice to have

18. Mobile public feedback reviews
19. Web locker scan history
20. Admin create-user form
21. Mount web Payments/{Success,Cancel,Error} pages
22. Xoá SwiftUI leftover trong `mobile/ios/Runner/SwiftUI/`
23. Token storage upgrade từ SharedPreferences → flutter_secure_storage
24. Mobile dùng `GET /orders/availability/slots` thay vì loop slot manually
25. Web `locker_detail` thêm nút "Open" + "Settings"

---

## 7. State management & real-time summary

### Web
- **Global Contexts**: `ThemeProvider`, `SettingsProvider`, `ToastProvider`
- **Feature Contexts**: `NotificationsProvider` (SignalR + polling fallback), `FeedbackProvider`
- **Realtime**: SignalR `notificationsRealtime.ts` (subscribe `NotificationReceived`), `paymentRealtime.ts` (subscribe `PaymentStatusChanged`)
- **HTTP**: `apiFetch` wrapper, single-flight refresh on 401

### Mobile
- **State**: Bloc + Cubit (`flutter_bloc` 8.1.6)
- **DI**: `get_it` 9.2.1 (`lib/core/routes/injection.dart`)
- **HTTP**: Dio singleton với Log + Timing + 401-refresh interceptors (`lib/core/network/api_client.dart`)
- **Realtime**: **CHƯA CÓ SignalR client** — chỉ polling/list thường

---

## 8. Phụ lục: thống kê entities & files

| Loại | Backend | Web | Mobile |
|---|---|---|---|
| Controllers | 21 | — | — |
| CQRS files | 110+ | — | — |
| Domain entities | 23 | — | — |
| SignalR hubs | 1 | — | — |
| Background services | 2 | — | — |
| Routes | — | 35 | 33 |
| Feature folders | 17 | 17 | 30 |
| Reusable components | — | 12 | ~70+ widgets |
| State containers | — | 3 global + 2 feature contexts | ~50+ cubits/states |
| Repositories | — | per-feature | ~30 |

---

## 9. Tóm tắt nhanh

- **Mobile coverage ~ 60%** của backend (thiếu chính: booking, shipper, nửa order lifecycle, realtime SignalR, VNPay)
- **Web coverage ~ 70%** của backend (thiếu: QR scan, open locker, admin bookings/payments, admin package CRUD, dashboard đang mock, locker settings)
- **Cả 2 đều THIẾU**:
  - Shipper UI trên mobile (gap rất lớn)
  - Dashboard đang dùng mock trên web
  - Google login mobile chưa wire
  - SignalR subscribe trên mobile
- **Bug mobile**: Wallet transfer URL double-base
- **Leftover mobile**: SwiftUI marketing template trong `ios/Runner/SwiftUI/`

---

> Báo cáo được sinh tự động từ 3 subagent inventory chạy song song. Mọi phát hiện dựa trên đọc file thật (read-only), không suy diễn từ tên file.