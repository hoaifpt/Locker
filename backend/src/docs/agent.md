# AI Agent Working Guidelines

Tài liệu này được tạo ra để cung cấp bối cảnh (context) và các quy tắc (rules) cho bất kỳ AI Agent nào tiếp quản dự án này trong tương lai.

## 1. Project Context

- **Tên dự án:** Locker Backend
- **Kiến trúc:** Clean Architecture + CQRS + MediatR.
- **Tech Stack:**
  - .NET 10 (C# 12+)
  - MongoDB (Code-First) thông qua `MongoDB.Driver` và `AspNetCore.Identity.MongoDbCore`.
  - CQRS sử dụng `MediatR`.
  - Validation sử dụng `FluentValidation` (tích hợp qua MediatR pipeline).
  - Authentication: JWT Bearer.

## 2. Quá trình làm việc trước đây (What was done)

1. Hệ thống ban đầu sử dụng các Service truyền thống (ví dụ: `IUserService`, `IAuthService` với rất nhiều methods hỗn tạp).
2. Toàn bộ `Services` đã bị xoá và kiến trúc được refactor hoàn toàn sang mô hình CQRS sử dụng `MediatR`.
3. Identity Framework được thiết kế lại để bóc tách khỏi `Domain`. `Locker.Backend.Domain` hiện tại **HOÀN TOÀN KHÔNG** phụ thuộc vào MongoDB hay ASP.NET Identity.
4. Đã tự động sinh (scaffold) và triển khai thành công 100% các APIs còn thiếu trong tài liệu mobile `MISSING_APIS.md` bao gồm các tính năng lớn: Wallet, Food Orders, Delivery Requests, Send/Receive Orders, Device Tokens.

## 3. Quy trình thêm một tính năng mới (How to add a new Feature)

Khi người dùng yêu cầu thêm một tính năng hoặc API mới, Agent cần tuân thủ tuyệt đối quy trình sau (tránh phá vỡ Clean Architecture):

**Bước 1: Domain Layer (`Locker.Backend.Domain`)**
- Tạo các C# class cho Entities tại thư mục `Entities`.
- Entities PHẢI kế thừa từ `BaseEntity` (điều này giúp tự sinh `Guid Id` bằng thuật toán V7).
- Tạo các file cho `Enums` (nếu cần).
- *Lưu ý:* Tuyệt đối không thêm bất kỳ Using nào liên quan tới Entity Framework, MongoDB hay ASP.NET vào lớp Domain.

**Bước 2: Application Layer (`Locker.Backend.Application`)**
- Định nghĩa Interface cho Repository tại `Interfaces` (Kế thừa từ `IGenericRepository<YourEntity>`).
- Định nghĩa `Models/DTOs` để làm kiểu dữ liệu trả về cho API.
- Tạo một thư mục con trong `Features/` ứng với Feature đang làm. (Ví dụ: `Features/YourFeature/Commands/...`, `Features/YourFeature/Queries/...`).
- Mỗi Endpoint tương ứng với 1 file Command (hoặc Query) + Handler độc lập (Single Responsibility).
- Inject Interface Repository vào Handler, không inject MongoDb Context.

**Bước 3: Infrastructure Layer (`Locker.Backend.Infrastructure`)**
- Bổ sung property vào `Mongo/MongoSettings.cs` để khai báo collection mới.
- Tạo class Repository thực tế tại `Repositories` kế thừa từ `GenericRepository<YourEntity>` và implement Interface ở trên.
- Đăng ký DI trong `DependencyInjection.cs`:
  `services.AddScoped<IYourEntityRepository, YourEntityRepository>();`

**Bước 4: Presentation Layer (`Locker.Backend`)**
- Thêm `Controller` mới trong thư mục `Controllers`.
- Inject `ISender _sender` (MediatR) vào Controller qua constructor.
- Extract `userId` (nếu có Auth) bằng hàm lấy claim, truyền vào Command/Query.
- Bắn Request vào MediatR: `await _sender.Send(new YourCommand(...))`. Trả về OK() hoặc các Status tương ứng.

## 4. Các Lưu ý Quan Trọng Khác (Crucial Rules)

1. **NO Entity Framework (EF Core):** Dự án sử dụng MongoDB thuần tuý qua package `MongoDB.Driver`. Agent tuyệt đối không được gọi lệnh tạo Migration hay code `DbContext` kiểu của SQL.
2. **Collection Naming:** Các Mongo collection được định nghĩa trong file `MongoSettings.cs` (ví dụ: `wallet_transactions`, `food_orders`). Tên theo chuẩn `snake_case` số nhiều.
3. **Mã hoá Mật khẩu:** Hãy sử dụng `IPasswordHasher` có sẵn trong `Locker.Backend.Application.Interfaces` khi cần băm mật khẩu hay PIN (không dùng thư viện ngoài).
4. **Luôn Build Code:** Sau khi thêm/sửa, hãy chạy lệnh `dotnet build d:\GitHub\Locker\backend\src\Locker.Backend\Locker.Backend.csproj` để chắc chắn code không có lỗi compile (như thiếu using, sai logic).
