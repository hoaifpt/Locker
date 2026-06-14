# Architecture Documentation

Du an Locker Backend duoc thiet ke dua tren cac nguyen tac cua **Clean Architecture** va mo hinh **CQRS (Command Query Responsibility Segregation)**. He thong cung cap mot API RESTful xay dung tren nen tang .NET 10 va su dung MongoDB lam co so du lieu chinh.

---

## 1. Tong Quan Kien Truc (Clean Architecture)

He thong duoc chia lam 4 du an (Projects) doc lap, co quy tac phu thuoc mot chieu huong vao trung tam (Domain).

```
Locker.Backend (API / Presentation)
       |
       v
Locker.Backend.Infrastructure (Data / External Services)
       |
       v
Locker.Backend.Application (Business Logic / CQRS)
       |
       v
Locker.Backend.Domain (Enterprise Business Rules)
```

### 1.1 Locker.Backend.Domain (Loi trung tam)

- **Trach nhiem:** Chua cac nguyen tac nghiep vu cot loi, hoan toan **khong** phu thuoc vao bat ky cong nghe, framework (nhu ASP.NET hay MongoDB) nao.
- **Thanh phan chinh:**
  - `Entities`: Cac thuc the chinh cua he thong nhu `User`, `Role`, `Locker`, `LockerSlot`, `Package`, `Order`, `Booking`, `Payment`, `WalletTransaction`, `FoodOrder`, `Restaurant`, `MenuItem`, `DeliveryRequest`, `SendReceiveOrder`, `DeviceToken`, `Notification`, `LockerEvent`, `RefreshToken`, `OtpCode`. Tat ca ke thua tu `BaseEntity` voi khoa chinh la `Guid` (Su dung Guid V7 de co the sap xep theo thoi gian).
  - `Enums`: Cac tap gia tri trang thai nghiep vu: `UserRole`, `OrderStatus`, `FoodOrderStatus`, `DeliveryStatus`, `SendReceiveStatus`, `LockerSlotStatus`, `BookingStatus`, `PaymentStatus`, `TransactionType`, `TransactionStatus`.

### 1.2 Locker.Backend.Application (Use Cases)

- **Trach nhiem:** Chua cac quy tac nghiep vu ung dung (Use Cases). Trien khai mo hinh CQRS bang `MediatR`. Phu thuoc vao `Domain`, nhung khong phu thuoc vao cong nghe co so du lieu.
- **Thanh phan chinh:**
  - `Interfaces`: Chua dinh nghia cac Interface de giao tiep voi ben ngoai (Vi du: `IGenericRepository<T>`, `IJwtTokenService`, `IEmailService`, `IPasswordHasher`, `IIdentifierValidator`).
  - `Features (CQRS)`:
    - **Commands**: Dai dien cho cac tac vu thay doi du lieu (CUD - Create, Update, Delete). Bao gom `Command` va `CommandHandler`.
    - **Queries**: Dai dien cho cac tac vu lay du lieu (Read). Bao gom `Query` va `QueryHandler`.
    - Cac Commands/Queries theo Feature: `Auth`, `Users`, `Lockers`, `Orders`, `Payments`, `Bookings`, `Packages`, `Wallet`, `FoodOrders`, `Restaurants`, `DeliveryRequests`, `SendReceiveOrders`, `Notifications`, `DeviceTokens`, `LockerEvents`, `Admin`.
  - `Models/DTOs`: Cac object de truyen tai du lieu giua cac layer.
  - `Behaviors`: Validation Pipeline thong qua `FluentValidation` tich hop thang vao chuoi xu ly cua MediatR.

### 1.3 Locker.Backend.Infrastructure

- **Trach nhiem:** Cung cap implementation thuc te cho cac `Interfaces` dinh nghia o Application. Day la noi duy nhat giao tiep truc tiep voi Database, He thong File, Email, hoac API ben thu ba.
- **Thanh phan chinh:**
  - `Repositories`: Chua base `GenericRepository<T>` va cac Repository cu the. Giao tiep truc tiep voi MongoDB su dung thu vien `MongoDB.Driver`.
  - `MongoContext` / `MongoSettings`: Quan ly ket noi den MongoDB, dinh nghia ten collection.
  - `Identity`: Tich hop ASP.NET Core Identity tren nen tang MongoDB thong qua package `AspNetCore.Identity.MongoDbCore`.
  - `Services`: Chua thuc thi cua `JwtTokenService`, `EmailService`, `PasswordHasher`, `IdentifierValidator`.

### 1.4 Locker.Backend (Presentation / API)

- **Trach nhiem:** Tiep nhan HTTP Request, routing, authentication/authorization, va chuyen giao Request xuong Application layer (thong qua `ISender` / MediatR).
- **Thanh phan chinh:**
  - `Controllers`: Khong chua business logic. Chi validate format co ban, trich xuat thong tin nguoi dung tu JWT (claims), goi Command/Query, va map ket qua thanh HTTP Response phu hop (Ok, NotFound, BadRequest, Unauthorized, Conflict).
  - `Program.cs`: Cau hinh Dependency Injection, Middleware, Swagger, CORS, Rate Limiting, Authentication, Authorization.
  - `DbSeeder`: Khoi tao du lieu Admin mac dinh (neu chua co).

---

## 2. Cac Mau Thiet Ke Ap Dung (Design Patterns)

1. **CQRS Pattern:** Phan tach ro rang tac vu lam thay doi trang thai (Command) va tac vu doc trang thai (Query). Giup code de bao tri, de thay doi luong xu ly va co the ap dung caching de dang cho Query.

2. **Mediator Pattern (`MediatR`):** Giam su phu thuoc cheo (coupling) giua Controller va cac Service. Controller chi "ban" ra mot object (Request), MediatR tu dong tim Handler xu ly.

3. **Repository Pattern:** Abstract hoa cac thao tac voi Database. Ung dung khong truc tiep goi `MongoCollection`, ma tuong tac qua `IRepository`.

4. **Dependency Injection (DI):** Tat ca dich vu, kho luu tru deu duoc tiem thong qua Constructor, dam bao nguyen tac Inversion of Control.

---

## 3. Quan Ly Du Lieu (MongoDB Code-First)

He thong su dung MongoDB lam DB, ap dung co che **Code First**:
- Khoi tao models trong `C#` -> Application.
- Database Collections se tu dong duoc tao/bo sung tai lieu khi co ban ghi (document) dau tien duoc them vao.
- Khong can su dung cac thu vien Migration cong kenh nhu EF Core.

**Danh sach Collections chinh:**

| Collection | Entity | Description |
|-----------|--------|-------------|
| `users` | User | Nguoi dung (ASP.NET Identity) |
| `roles` | Role | Vai tro |
| `lockers` | Locker | Tu locker |
| `packages` | Package | Goi dich vu |
| `bookings` | Booking | Dat cho (legacy) |
| `orders` | Order | Don hang moi |
| `payments` | Payment | Thanh toan |
| `wallet_transactions` | WalletTransaction | Giao dich vi |
| `food_orders` | FoodOrder | Don hang mon an |
| `restaurants` | Restaurant | Nha hang |
| `menu_items` | MenuItem | Mon an |
| `delivery_requests` | DeliveryRequest | Yeu cau giao hang |
| `send_receive_orders` | SendReceiveOrder | Gui/nhan do |
| `device_tokens` | DeviceToken | Push notification tokens |
| `notifications` | Notification | Thong bao |
| `locker_events` | LockerEvent | Su kien tu locker |
| `refresh_tokens` | RefreshToken | Refresh tokens |
| `otp_codes` | OtpCode | Ma OTP |

---

## 4. API Endpoints Overview

### 4a. Auth Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/login` | No | Login voi identifier (email/phone) + password |
| POST | `/api/auth/register` | No | Register nguoi dung moi, tra ve token |
| GET | `/api/auth/verify-email` | No | Xac thuc email qua token |
| POST | `/api/auth/resend-verification` | No | Gui lai email xac thuc |
| POST | `/api/auth/refresh` | No | Refresh access token |
| POST | `/api/auth/logout` | Yes | Logout (thu hoi token) |
| POST | `/api/auth/logout-all` | Yes | Logout tat ca thiet bi |
| POST | `/api/auth/forgot-password` | No | Gui ma OTP ve email |
| POST | `/api/auth/reset-password` | No | Dat lai mat khau voi OTP |

### 4b. User Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/users/me` | Yes | Lay thong tin profile hien tai |
| PUT | `/api/users/me` | Yes | Cap nhat profile |
| POST | `/api/users/me/change-password` | Yes | Doi mat khau |

### 4c. Locker Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/lockers` | Yes | Lay tat ca lockers (Admin) |
| GET | `/api/lockers/available` | No | Lay locker trong |
| GET | `/api/lockers/map` | No | Lay ban do locker |
| GET | `/api/lockers/{id}` | Yes | Lay chi tiet locker |
| POST | `/api/lockers` | Admin | Tao locker moi |
| PUT | `/api/lockers/{id}` | Admin | Cap nhat locker |
| DELETE | `/api/lockers/{id}/soft-delete` | Admin | Xoa mem locker |
| POST | `/api/lockers/{id}/open` | Yes | Mo ngăn tu |
| POST | `/api/lockers/qr-scan` | No | Validate QR code |
| GET | `/api/lockers/scan-history` | No | Lich su quet QR |
| PATCH | `/api/lockers/{id}/settings` | Admin | Cap nhat cai dat |
| PATCH | `/api/lockers/{id}/slots/{slotIndex}/status` | Admin/Shipper | Cap nhat trang thai ngăn |
| POST | `/api/lockers/{id}/slots/{slotIndex}/open-event` | Admin/Shipper | Bao cao mo ngăn |

### 4d. Order Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/orders/my` | Yes | Lay don hang cua toi |
| GET | `/api/orders/{id}` | Yes | Lay chi tiet don |
| POST | `/api/orders/reserve` | Yes | Dat cho (reserve slot) |
| PATCH | `/api/orders/{id}/confirm` | Yes | Xac nhan (sau khi thanh toan) |
| POST | `/api/orders/{id}/set-pin` | Yes | Dat PIN |
| PATCH | `/api/orders/{id}/activate` | Yes | Kich hoat (mo ngăn) |
| PATCH | `/api/orders/{id}/complete` | Yes | Hoan thanh don |
| PATCH | `/api/orders/{id}/cancel` | Yes | Huy don |
| POST | `/api/orders/{id}/extend` | Yes | Gia han |
| GET | `/api/orders/availability/slots` | No | Lay slot trong theo thoi gian |
| PATCH | `/api/orders/{id}/payment-link` | Admin | Lien ket thanh toan |

### 4e. Payment Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/payments/{id}` | Yes | Lay chi tiet thanh toan |
| GET | `/api/payments/booking/{bookingId}` | Yes | Lay thanh toan theo booking |
| GET | `/api/payments/my` | Yes | Lay lich su thanh toan |
| POST | `/api/payments` | Yes | Tao thanh toan moi |
| POST | `/api/payments/{id}/complete` | Yes | Hoan thanh thanh toan |
| POST | `/api/payments/webhook` | No | Webhook tu VnPay/MoMo |

### 4f. Wallet Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/wallet/overview` | Yes | Tong quan vi (balance + recent count) |
| GET | `/api/wallet/transactions` | Yes | Lich su giao dich |
| GET | `/api/wallet/balance` | Yes | So du |
| POST | `/api/wallet/top-up` | Yes | Nap tien truc tiep |
| POST | `/api/wallet/top-up/vnpay/init` | Yes | Khoi tao nap tien VnPay |
| GET | `/api/wallet/top-up/vnpay/return` | No | Callback VnPay |
| POST | `/api/wallet/transfer` | Yes | Chuyen tien |

### 4g. Food Order Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/restaurants` | Yes | Lay danh sach nha hang |
| GET | `/api/restaurants/{id}` | Yes | Lay chi tiet nha hang |
| GET | `/api/restaurants/{id}/menu` | Yes | Lay menu |
| GET | `/api/food-orders/my` | Yes | Lay don hang cua toi |
| GET | `/api/food-orders/{id}` | Yes | Lay chi tiet don |
| POST | `/api/food-orders` | Yes | Tao don hang (tu dong tao Payment pending) |

### 4h. Delivery Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/delivery/package-sizes` | No | Lay cac kich thuoc goi |
| GET | `/api/delivery/requests/my` | Yes | Lay yeu cau cua toi |
| GET | `/api/delivery/requests/track/{trackingCode}` | No | Theo doi bang ma |
| POST | `/api/delivery/requests` | Yes | Tao yeu cau giao hang |

### 4i. Send/Receive Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/send-receive/orders/my` | Yes | Lay don gui/nhan cua toi |
| GET | `/api/send-receive/orders/{id}` | Yes | Lay chi tiet |
| POST | `/api/send-receive/orders` | Yes | Tao don gui (can pinCode) |
| PATCH | `/api/send-receive/orders/{id}/confirm` | Yes | Xac nhan nhan hang |
| PATCH | `/api/send-receive/orders/{id}/complete` | Yes | Hoan thanh |

### 4j. Package Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/packages` | No | Lay tat ca goi |
| GET | `/api/packages/{id}` | No | Lay chi tiet goi |
| PUT | `/api/packages/{id}` | Admin | Cap nhat goi |
| DELETE | `/api/packages/{id}` | Admin | Xoa goi |

### 4k. Other Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/notifications/my` | Yes | Lay thong bao |
| POST | `/api/notifications/{id}/mark-as-read` | Yes | Danh dau da doc |
| POST | `/api/notifications/mark-all-as-read` | Yes | Danh dau tat ca da doc |
| POST | `/api/notifications/register-device` | Yes | Dang ky device token |
| GET | `/api/admin/dashboard` | Admin | Dashboard |
| GET | `/api/admin/lockers` | Admin | Quan ly lockers |
| GET | `/api/admin/payments` | Admin | Quan ly thanh toan |
| GET | `/api/health` | No | Health check |

---

## 5. Business Flows

### 5a. Order Flow (Dat tu / Dat cho)

```
1. User chon locker + slot
2. POST /api/orders/reserve
   -> Tao Order (status: Initiated), reserve slot
   -> Tra ve orderId + totalAmount + expirationTime
3. POST /api/payments
   -> Tao Payment (status: Pending)
4. [Thanh toan VnPay/MoMo/Wallet]
   -> Webhook -> Payment status = Completed
5. PATCH /api/orders/{id}/confirm
   -> Check Payment da Completed
   -> Update Order status = Reserved
6. PATCH /api/orders/{id}/activate (trong khung gio check-in)
   -> Update Order status = Active
   -> Mo ngăn
7. POST /api/orders/{id}/set-pin
8. PATCH /api/orders/{id}/complete
   -> Update Order status = Completed
   -> Giai phong ngăn
```

### 5b. Food Order Flow

```
1. User xem restaurants + menu
2. POST /api/food-orders
   Body: { restaurantId, lockerId, slotIndex, items, deliveryNotes? }
   -> Tao FoodOrder + Payment (Pending)
3. [Thanh toan]
4. Shipper giao do an vao ngăn
5. User nhan do an
```

### 5c. Send/Receive Flow

```
1. User tao don gui
   POST /api/send-receive/orders
   Body: { lockerId, slotIndex, receiverPhone, pinCode, notes? }
2. Nguoi nhan nhan ma
3. Nguoi nhan xac nhan (PICKUP) -> PATCH /confirm
4. Nguoi nhan hoan thanh -> PATCH /complete
```

### 5d. Wallet Top-up Flow (VnPay)

```
1. User nhap so tien
2. POST /api/wallet/top-up/vnpay/init
   -> Tra ve paymentUrl VnPay
3. User duoc chuyen huong sang VnPay
4. VnPay xu ly thanh toan
5. VnPay redirect ve /api/wallet/top-up/vnpay/return
6. Backend xu ly callback, cap nhat WalletTransaction
```

---

## 6. Security

- **Authentication**: JWT Bearer tokens (access + refresh)
- **Authorization**: Role-based (User, Admin, Shipper)
- **Password**: Bcrypt qua `IPasswordHasher`
- **PIN**: Bcrypt hashing
- **Webhook**: HMAC-SHA256 signature verification
- **Rate Limiting**: Applied tren Auth endpoints

---

## 7. Project Structure

```
backend/src/
├── Locker.Backend/
│   ├── Controllers/          # 17 Controllers
│   ├── Program.cs
│   └── appsettings.json
├── Locker.Backend.Application/
│   ├── Features/
│   │   ├── Admin/
│   │   ├── Auth/
│   │   ├── Bookings/
│   │   ├── DeliveryRequests/
│   │   ├── DeviceTokens/
│   │   ├── FoodOrders/
│   │   ├── LockerEvents/
│   │   ├── Lockers/
│   │   ├── Notifications/
│   │   ├── Orders/
│   │   ├── Packages/
│   │   ├── Payments/
│   │   ├── Restaurants/
│   │   ├── SendReceiveOrders/
│   │   ├── Users/
│   │   └── Wallet/
│   ├── Interfaces/
│   ├── Mapping/
│   ├── Models/
│   └── Behaviors/
├── Locker.Backend.Domain/
│   ├── Entities/             # 18 Entities
│   └── Enums/                # 10 Enums
├── Locker.Backend.Infrastructure/
│   ├── Mongo/
│   ├── Repositories/
│   ├── Identity/
│   └── Services/
└── docs/
    ├── agent.md
    ├── architecture.md
    └── flutter_api_integration_plan_1aca8bd0.plan.md
```
