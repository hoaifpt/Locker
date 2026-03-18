# 🌱 Database Seed Data Guide

## Overview
Hệ thống tự động seed dữ liệu vào MongoDB khi ứng dụng khởi động (nếu chưa tồn tại).

## Dữ Liệu Được Seed

### 👥 **Users (5 người)**
| Username | Email | Password | Role | Phone |
|----------|-------|----------|------|-------|
| admin | admin@locker.com | Admin@123 | Admin | +84901234567 |
| john_doe | john.doe@example.com | John@1234 | User | +84912345678 |
| jane_smith | jane.smith@example.com | Jane@1234 | User | +84923456789 |
| mike_wilson | mike.wilson@example.com | Mike@1234 | User | +84934567890 |
| alice_brown | alice.brown@example.com | Alice@1234 | User | +84945678901 |

### 📦 **Packages (4 loại)**
| Size | Name | PricePerHour | Description |
|------|------|--------------|-------------|
| S | Small Box | 5,000 VND | 20x20x20cm |
| M | Medium Box | 10,000 VND | 30x30x30cm |
| L | Large Box | 15,000 VND | 40x40x40cm |
| XL | Extra Large | 20,000 VND | 50x50x50cm |

### 🔐 **Lockers (4 tủ khóa)**
| Name | Location | Slots | Address |
|------|----------|-------|---------|
| Station A | Thao Dien | 12 | Diamond Plaza, D2, HCMC |
| Station B | Binh Thanh | 15 | Landmark 81, D1, HCMC |
| Station C | Tan Binh | 20 | Ga tàu ngầm Tan Binh, D3, HCMC |
| Station D | Ben Thanh | 10 | Chợ Bến Thành, D1, HCMC |

**Tổng cộng: 57 slots**

### 📋 **Orders (6 đơn hàng) - Đủ các trạng thái**

#### 1. ✅ **Completed** - Hoàn thành
- **User**: john_doe
- **Locker**: Station A, Slot 0
- **Package**: Small (5,000 VND/h)
- **Duration**: 2 giờ
- **Total**: 11,000 VND (bao gồm 10% tax)
- **Status**: Completed 3 ngày trước
- **Payment**: ✓ Card - Transferred

#### 2. 🔴 **Active** - Đang sử dụng
- **User**: jane_smith
- **Locker**: Station B, Slot 1
- **Package**: Medium (10,000 VND/h)
- **Duration**: 5 giờ
- **Total**: 55,000 VND
- **Status**: Đang sử dụng (started 1h ago)
- **Payment**: ✓ Momo - Completed

#### 3. 💾 **Reserved** - Đã giữ chỗ (Paid, chờ kích hoạt)
- **User**: mike_wilson
- **Locker**: Station A, Slot 5
- **Package**: Large (15,000 VND/h)
- **Duration**: 24 giờ (1 ngày)
- **Total**: 165,000 VND
- **Status**: Reserved, check-in sau 2h
- **Payment**: ✓ VNPay - Completed

#### 4. ⏳ **Initiated** - Vừa tạo (chờ thanh toán)
- **User**: alice_brown
- **Locker**: Station C, Slot 10
- **Package**: Medium (10,000 VND/h)
- **Duration**: 3 giờ
- **Total**: 33,000 VND
- **Status**: Initiated - hết hạn thanh toán trong 15 phút
- **Payment**: ⏳ Pending

#### 5. ❌ **Cancelled** - Đã hủy
- **User**: john_doe
- **Locker**: Station D, Slot 3
- **Package**: Small (5,000 VND/h)
- **Duration**: 3 giờ
- **Total**: 16,500 VND
- **Status**: Cancelled 2 ngày trước
- **Reason**: User changed their mind
- **Payment**: N/A

#### 6. 💳 **Paid** - Đã thanh toán (chờ kích hoạt)
- **User**: jane_smith
- **Locker**: Station B, Slot 7
- **Package**: Extra Large (20,000 VND/h)
- **Duration**: 6 giờ
- **Total**: 132,000 VND
- **Status**: Paid, kích hoạt trong 30 phút
- **Payment**: ✓ ZaloPay - Completed

### 💰 **Payments (4 payment)**
- 3 payments Completed (cho orders completed, active, paid)
- 4 payment methods: Card, Momo, VNPay, ZaloPay

### 📅 **Bookings (2 bookings - Legacy)**
- 1 Completed booking
- 1 Active booking

---

## 🚀 Cách Sử Dụng

### 1. **Khởi động ứng dụng**
```bash
cd backend
dotnet run --project src/Locker.Backend
```

### 2. **Seed data sẽ tự động tạo**
```
========== DATABASE SEEDING START ==========

📝 Seeding Users...
   ✓ 5 users created
📦 Seeding Packages...
   ✓ 4 packages created
🔐 Seeding Lockers and Slots...
   ✓ 4 lockers with 57 slots created
📋 Seeding Orders and Payments...
   ✓ 6 orders and 4 payments created
📅 Seeding Bookings (Legacy)...
   ✓ 2 bookings created

========== DATABASE SEEDING COMPLETE ==========
```

### 3. **Truy cập API thông qua Swagger**
```
http://localhost:5000/swagger
```

---

## 🧪 Test Cases Có Thể Thực Hiện

### **Test User Authentication**
```bash
# Login with user
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"john_doe","password":"John@1234"}'
```

### **Test Order Workflow**
```bash
# 1. Get available slots
GET /api/orders/availability/slots?lockerId=...&fromTime=2024-01-01T00:00:00Z&toTime=2024-01-02T00:00:00Z

# 2. Create new order (reserve)
POST /api/orders/reserve
{
  "lockerId": "...",
  "slotIndex": 2,
  "packageId": "...",
  "mobileNumber": "+84912345678",
  "checkInTime": "2024-01-02T10:00:00Z",
  "durationHours": 5
}

# 3. Confirm order (after payment)
PATCH /api/orders/{orderId}/confirm

# 4. Set PIN
POST /api/orders/{orderId}/set-pin
{"pin": "1234"}

# 5. Activate
PATCH /api/orders/{orderId}/activate

# 6. Complete
PATCH /api/orders/{orderId}/complete
```

### **Test Order Cancellation**
```bash
PATCH /api/orders/{orderId}/cancel
{
  "cancellationReason": "Changed my mind"
}
```

### **Test Order Extension**
```bash
POST /api/orders/{orderId}/extend
{
  "additionalHours": 2
}
```

### **Test Get My Orders**
```bash
GET /api/orders/my?status=Active
```

---

## 📊 Thống Kê Dữ Liệu

- **Total Users**: 5 (1 Admin, 4 Regular)
- **Total Packages**: 4
- **Total Lockers**: 4
- **Total Slots**: 57
- **Total Orders**: 6
- **Order States Coverage**: 6/6 (all statuses)
- **Total Payments**: 4
- **Legacy Bookings**: 2

---

## ⚙️ Cấu Hình Seeding

Seeding chỉ xảy ra nếu:
1. Ứng dụng khởi động lần đầu hoặc database chưa init
2. Nếu admin user đã tồn tại, skip users seeding nhưng tiếp tục seed packages, lockers, orders

## 🔄 Xóa Seed Data

Để xóa tất cả seed data và seeding lại:

```bash
# 1. Kết nối MongoDB
mongo

# 2. Xóa database
use locker
db.dropDatabase()

# 3. Khởi động lại ứng dụng
dotnet run
```

---

## 📝 Dữ Liệu Credentials

### **Admin Account**
- Username: `admin`
- Password: `Admin@123`
- Role: `Admin`

### **User Accounts (cho testing thông thường)**
- Username: `john_doe` / Password: `John@1234`
- Username: `jane_smith` / Password: `Jane@1234`
- Username: `mike_wilson` / Password: `Mike@1234`
- Username: `alice_brown` / Password: `Alice@1234`

---

## 🎯 Testing Tips

1. **Test Order Flow**: Sử dụng Order #4 (Initiated) để test toàn bộ checkout flow
2. **Test Extension**: Sử dụng Order #2 (Active) hoặc #6 (Paid)
3. **Test Availability Check**: Sử dụng các locker khác nhau
4. **Test Cancellation Policy**: Xem Order #5 (Cancelled)
5. **Test Multiple Users**: Tất cả 6 orders là của các users khác nhau

---

**Last Updated**: March 18, 2026
**Backend Version**: .NET 8.0
**Database**: MongoDB
