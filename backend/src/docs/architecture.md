# Architecture Documentation

Dự án Locker Backend được thiết kế dựa trên các nguyên tắc của **Clean Architecture** và mô hình **CQRS (Command Query Responsibility Segregation)**. Hệ thống cung cấp một API RESTful xây dựng trên nền tảng .NET 10 và sử dụng MongoDB làm cơ sở dữ liệu chính.

## 1. Tổng quan Kiến trúc (Clean Architecture)

Hệ thống được chia làm 4 dự án (Projects) độc lập, có quy tắc phụ thuộc một chiều hướng vào trung tâm (Domain).

```text
Locker.Backend (API / Presentation)
       │
       ▼
Locker.Backend.Infrastructure (Data / External Services)
       │
       ▼
Locker.Backend.Application (Business Logic / CQRS)
       │
       ▼
Locker.Backend.Domain (Enterprise Business Rules)
```

### 1.1 Locker.Backend.Domain (Lõi trung tâm)
- **Trách nhiệm:** Chứa các nguyên tắc nghiệp vụ cốt lõi, hoàn toàn **không** phụ thuộc vào bất kỳ công nghệ, framework (như ASP.NET hay MongoDB) nào.
- **Thành phần chính:**
  - `Entities`: Các thực thể chính của hệ thống như `User`, `Role`, `Locker`, `FoodOrder`, `WalletTransaction`, v.v. Tất cả kế thừa từ `BaseEntity` với khoá chính là `Guid` (Sử dụng Guid V7 để có thể sắp xếp theo thời gian).
  - `Enums`: Các tập giá trị trạng thái nghiệp vụ.

### 1.2 Locker.Backend.Application (Use Cases)
- **Trách nhiệm:** Chứa các quy tắc nghiệp vụ ứng dụng (Use Cases). Triển khai mô hình CQRS bằng `MediatR`. Phụ thuộc vào `Domain`, nhưng không phụ thuộc vào công nghệ cơ sở dữ liệu.
- **Thành phần chính:**
  - `Interfaces`: Chứa định nghĩa các Interface để giao tiếp với bên ngoài (Ví dụ: `IGenericRepository<T>`, `IJwtTokenService`).
  - `Features (CQRS)`:
    - **Commands**: Đại diện cho các tác vụ thay đổi dữ liệu (CUD - Create, Update, Delete). Bao gồm `Command` và `CommandHandler`.
    - **Queries**: Đại diện cho các tác vụ lấy dữ liệu (Read). Bao gồm `Query` và `QueryHandler`.
  - `Models/DTOs`: Các object để truyền tải dữ liệu giữa các layer.
  - `Behaviors`: Validation Pipeline thông qua `FluentValidation` tích hợp thẳng vào chuỗi xử lý của MediatR.

### 1.3 Locker.Backend.Infrastructure
- **Trách nhiệm:** Cung cấp implementation thực tế cho các `Interfaces` định nghĩa ở Application. Đây là nơi duy nhất giao tiếp trực tiếp với Database, Hệ thống File, Email, hoặc API bên thứ ba.
- **Thành phần chính:**
  - `Repositories`: Chứa base `GenericRepository<T>` và các Repository cụ thể. Giao tiếp trực tiếp với MongoDB sử dụng thư viện `MongoDB.Driver`.
  - `MongoContext` / `MongoSettings`: Quản lý kết nối đến MongoDB.
  - `Identity`: Tích hợp ASP.NET Core Identity trên nền tảng MongoDB thông qua package `AspNetCore.Identity.MongoDbCore`.
  - `Services`: Chứa thực thi của `IJwtTokenService`, `IEmailService`, `IIdentifierValidator`.

### 1.4 Locker.Backend (API / Presentation)
- **Trách nhiệm:** Tiếp nhận HTTP Request, routing, authentication/authorization, và chuyển giao Request xuống Application layer (thông qua `ISender` / MediatR).
- **Thành phần chính:**
  - `Controllers`: Không chứa business logic. Chỉ validate format cơ bản, trích xuất thông tin người dùng từ JWT (claims), gọi Command/Query, và map kết quả thành HTTP Response phù hợp (Ok, NotFound, BadRequest).
  - `Program.cs`: Cấu hình Dependency Injection, Middleware, Swagger, CORS, Rate Limiting.
  - `DbSeeder`: Khởi tạo dữ liệu Admin mặc định (nếu chưa có).

---

## 2. Các Mẫu Thiết Kế Áp Dụng (Design Patterns)

1. **CQRS Pattern:** Phân tách rõ ràng tác vụ làm thay đổi trạng thái (Command) và tác vụ đọc trạng thái (Query). Giúp code dễ bảo trì, dễ thay đổi luồng xử lý và có thể áp dụng caching dễ dàng cho Query.
2. **Mediator Pattern (`MediatR`):** Giảm sự phụ thuộc chéo (coupling) giữa Controller và các Service. Controller chỉ "bắn" ra một object (Request), MediatR tự động tìm Handler xử lý.
3. **Repository Pattern:** Abstract hóa các thao tác với Database. Ứng dụng không trực tiếp gọi `MongoCollection`, mà tương tác qua `IRepository`.
4. **Dependency Injection (DI):** Tất cả dịch vụ, kho lưu trữ đều được tiêm thông qua Constructor, đảm bảo nguyên tắc Inversion of Control.

---

## 3. Quản Lý Dữ Liệu (MongoDB Code-First)

Hệ thống sử dụng MongoDB làm DB, áp dụng cơ chế **Code First**:
- Khởi tạo models trong `C#` -> Application.
- Database Collections sẽ tự động được tạo/bổ sung tài liệu khi có bản ghi (document) đầu tiên được thêm vào.
- Không cần sử dụng các thư viện Migration cồng kềnh như EF Core.

**Danh sách Collections chính:**
- `users`, `roles`: Lưu trữ Identity theo cấu trúc chuẩn của ASP.NET.
- `lockers`, `packages`, `bookings`: Quản lý phần cứng và trạng thái bưu kiện.
- `wallet_transactions`, `food_orders`, `delivery_requests`, `send_receive_orders`: Mở rộng cho các nhóm nghiệp vụ thanh toán và đặt hàng.
- `device_tokens`, `notifications`: Phục vụ hệ thống gửi Push Notification.
