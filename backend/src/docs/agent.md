# AI Agent Working Guidelines

Tai lieu nay cung cap boi canh (context) va quy tac (rules) cho bat ky AI Agent nao tiep quan du an Locker trong tuong lai.

---

## 1. Project Context

### 1a. Monorepo Structure

```
Locker/
├── backend/          # ASP.NET Core API (Clean Architecture + CQRS + MediatR)
├── mobile/          # Flutter app (Clean Architecture)
├── web/             # React + TypeScript
├── firmware/        # ESP32-S3 (ESP-IDF)
├── infra/           # Docker, MQTT, PostgreSQL
└── docs/            # Architecture, plans, specs
```

### 1b. Backend - Tech Stack

- **.NET 10** (C# 12+) + **Clean Architecture** + **CQRS** + **MediatR**
- **MongoDB** (Code-First) qua `MongoDB.Driver` va `AspNetCore.Identity.MongoDbCore`
- **Validation**: `FluentValidation` tich hop qua MediatR pipeline
- **Authentication**: JWT Bearer tokens (access + refresh tokens)
- **Payments**: VnPay integration (Wallet top-up flow)

### 1c. Backend Projects (4 layers)

```
Locker.Backend (Presentation / Controllers)
       |
Locker.Backend.Infrastructure (Repositories, MongoDB, Identity, Services)
       |
Locker.Backend.Application (CQRS Commands/Queries, MediatR Handlers, DTOs)
       |
Locker.Backend.Domain (Entities, Enums - hoan toan khong phu thuoc ASP.NET/MongoDB)
```

### 1d. Mobile - Tech Stack

- **Flutter** + **Dart**
- **State Management**: flutter_bloc (Cubit/BLoC pattern)
- **HTTP Client**: Dio
- **Local Storage**: shared_preferences, flutter_secure_storage
- **Clean Architecture**: domain/data/presentation layers

### 1e. Web - Tech Stack

- **React** + **TypeScript**
- Vite build tool
- Tailwind CSS

---

## 2. Current Implementation Status

### 2a. Backend - Fully Implemented APIs

| Module | Endpoints | Status |
|--------|-----------|--------|
| **Auth** | login, register, verify-email, resend-verification, refresh, logout, logout-all, forgot-password, reset-password | Done |
| **Users** | get profile, update profile, change-password | Done |
| **Lockers** | CRUD, available, map, open slot, qr-scan, scan-history, update settings, slot status, open event | Done |
| **Orders** | reserve, my, get by id, confirm, set-pin, activate, complete, cancel, extend, availability slots | Done |
| **Payments** | create, complete, get by id, get by booking, get my, webhook | Done |
| **Bookings** | create, my, get by id, set-pin, verify-pin, complete, cancel | Done |
| **Packages** | CRUD | Done |
| **Wallet** | overview, transactions, balance, top-up, transfer, VnPay init/return | Done |
| **Food Orders** | create, my, get by id | Done |
| **Restaurants** | get all, get by id, get menu | Done |
| **Delivery** | package-sizes, create, my, track | Done |
| **Send/Receive** | create, my, get by id, confirm, complete | Done |
| **Notifications** | my, mark as read, mark all as read, register device | Done |
| **Admin** | dashboard, lockers, payments | Done |
| **Device Tokens** | register | Done |
| **Locker Events** | create | Done |

### 2b. Mobile - Current Status

**HUONG DAN QUAN TRONG**: Mobile app hien dang su dung **mock data** trong cac repository. Can tich hop voi backend API theo `flutter_api_integration_plan_1aca8bd0.plan.md`.

Repositories dang dung mock data:
- `wallet_repository.dart` - mock data (can tich hop real API)
- `send_receive_repository.dart` - mock data (can tich hop real API)
- `delivery_repository.dart` - chua co (can tao moi)
- `food_order_repository.dart` - chua co (can tao moi)
- `orders_repository.dart` - chua co (can tao moi)

Backend API Contracts:
- `POST /api/auth/register` tra ve `{ token, refreshToken, username, role, expiresAt }`
- `GET /api/wallet/overview` tra ve `{ balance, recentTransactionsCount }` (KHONG co transactions)
- `POST /api/food-orders` can `lockerId` va `slotIndex`
- `POST /api/delivery/requests` can `senderName`
- `POST /api/send-receive/orders` can `pinCode`
- Orders flow: reserve -> POST /payments -> confirm -> activate -> complete
- Payments: POST /api/payments -> CompletePayment webhook

---

## 3. Database Schema (MongoDB Collections)

| Collection | Entity | Mieu ta |
|-----------|--------|---------|
| `users` | User | Nguoi dung (ASP.NET Identity) |
| `roles` | Role | Vai tro |
| `lockers` | Locker | Tu locker |
| `locker_slots` | LockerSlot | Ngăn trong tu |
| `packages` | Package | Goi dich vu |
| `bookings` | Booking | Dat cho (cu) |
| `orders` | Order | Don hang (moi) |
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

## 4. Quy Trinh Them Tinh Nang Moi (Backend)

Khi yeu cau them tinh nang hoac API moi, Agent can tuan thu tuyet doi quy trinh sau (tranh pha vong Clean Architecture):

### Buoc 1: Domain Layer (`Locker.Backend.Domain`)

- Tao cac C# class cho Entities tai thu muc `Entities`.
- Entities PHAI ke thua tu `BaseEntity` (tu dong sinh `Guid Id` bang thuat toan V7).
- Tao cac file cho `Enums` (neu can).
- LUu Y: Tuyet doi khong them bat ky Using nao lien quan toi Entity Framework, MongoDB hay ASP.NET vao lop Domain.

### Buoc 2: Application Layer (`Locker.Backend.Application`)

- Dinh nghia Interface cho Repository tai `Interfaces` (Ke thua tu `IGenericRepository<YourEntity>`).
- Dinh nghia `Models/DTOs` de lam kieu du lieu tra ve cho API.
- Tao mot thu muc con trong `Features/` ung voi Feature dang lam. (Vi du: `Features/YourFeature/Commands/...`, `Features/YourFeature/Queries/...`).
- Moi Endpoint tuong ung voi 1 file Command (hoac Query) + Handler doc lap (Single Responsibility).
- Inject Interface Repository vao Handler, khong inject MongoDb Context.

### Buoc 3: Infrastructure Layer (`Locker.Backend.Infrastructure`)

- Bo sung property vao `Mongo/MongoSettings.cs` de khai bao collection moi.
- Tao class Repository thuc te tai `Repositories` ke thua tu `GenericRepository<YourEntity>` va implement Interface o tren.
- Dang ky DI trong `DependencyInjection.cs`:
  `services.AddScoped<IYourEntityRepository, YourEntityRepository>();`

### Buoc 4: Presentation Layer (`Locker.Backend`)

- Them `Controller` moi trong thu muc `Controllers`.
- Inject `ISender _sender` (MediatR) vao Controller qua constructor.
- Extract `userId` (neu co Auth) bang ham lay claim, truyen vao Command/Query.
- Ban Request vao MediatR: `await _sender.Send(new YourCommand(...))`. Tra ve OK() hoac cac Status tuong ung.

---

## 5. Cai Dat Moi Truong (Development Setup)

### Backend

```powershell
# Khoi dong MongoDB (Docker)
docker run -d -p 27017:27017 --name mongodb mongo:latest

# Khoi dong backend
cd d:\GitHub\Locker\backend\src\Locker.Backend
dotnet run
# Hoac su dung dotnet watch
dotnet watch run

# Build de kiem tra loi
dotnet build d:\GitHub\Locker\backend\src\Locker.Backend\Locker.Backend.csproj
```

### Mobile

```bash
cd d:\GitHub\Locker\mobile
flutter pub get
flutter run
```

### Web

```bash
cd d:\GitHub\Locker\web
npm install
npm run dev
```

---

## 6. Cac Quy Tac Quan Trong Khac

1. **KHONG su dung Entity Framework (EF Core)**: Du an su dung MongoDB thuan tuy qua package `MongoDB.Driver`. Agent tuyet doi khong duoc goi lenh tao Migration hay code `DbContext` kieu cua SQL.

2. **Collection Naming**: Cac Mongo collection duoc dinh nghia trong file `MongoSettings.cs` (vi du: `wallet_transactions`, `food_orders`). Ten theo chuan `snake_case` so nhieu.

3. **Ma hoa Mat khau**: Hay su dung `IPasswordHasher` co san trong `Locker.Backend.Application.Interfaces` khi can bam mat khau hay PIN (khong dung thu vien ngoai).

4. **Luon Build Code**: Sau khi them/sua, hay chay lenh `dotnet build d:\GitHub\Locker\backend\src\Locker.Backend\Locker.Backend.csproj` de chan chan code khong co loi compile (nhu thieu using, sai logic).

5. **Flutter API Integration**: Truoc khi implement Flutter, doc kỹ `docs/flutter_api_integration_plan_1aca8bd0.plan.md`. Tat ca repositories hien tai dang dung mock data.

6. **API Test Tool**: Da co design spec tai `docs/superpowers/specs/2026-06-10-api-test-tool-design.md` va plan tai `docs/superpowers/plans/2026-06-10-api-test-tool.md`. Su dung tool nay de test cac API endpoints cua backend.

---

## 7. Thu Vien / Package Reference

### Backend NuGet Packages

- `MediatR` - CQRS mediator
- `FluentValidation` - Validation
- `MongoDB.Driver` - MongoDB driver
- `AspNetCore.Identity.MongoDbCore` - MongoDB Identity
- `Microsoft.AspNetCore.Authentication.JwtBearer` - JWT auth
- `Swashbuckle.AspNetCore` - Swagger/OpenAPI

### Mobile Dependencies

- `flutter_bloc` - State management
- `dio` - HTTP client
- `shared_preferences` - Local key-value storage
- `flutter_secure_storage` - Secure token storage
- `equatable` - Value equality
- `get_it` - Service locator / DI

---

## 8. Git Branch Strategy

- `main` - Branch chinh, production-ready
- `dev_2` - Branch phat trien hien tai (dang lam viec)
- Feature branches: `feature/<ten-tinh-nang>`
- Commit thuong xuyen voi message ro rang theo conventional commits:
  - `feat:` - Tinh nang moi
  - `fix:` - Sua loi
  - `docs:` - Tai lieu
  - `refactor:` - Tai cau truc code
  - `test:` - Them test
