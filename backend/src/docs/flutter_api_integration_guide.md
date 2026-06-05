# 🚀 TÀI LIỆU TÍCH HỢP API CHO FLUTTER (STEP-BY-STEP)
Dự án: Locker App Backend

Tài liệu này mô tả chi tiết các luồng (flows) tích hợp API từ phía Mobile App (Flutter) với hệ thống Backend C# .NET. Tất cả các endpoint đều có tiền tố `/api`. (Ví dụ: `http://localhost:5000/api/...`)

---

## 🛠 1. Cấu Hình Chung (Global Configuration)
- **Base URL:** `http://localhost:5000/api`
- **Headers yêu cầu cho các API cần xác thực:**
  ```json
  {
    "Content-Type": "application/json",
    "Authorization": "Bearer <YOUR_JWT_TOKEN_HERE>"
  }
  ```

---

## 🔐 LUỒNG 1: XÁC THỰC VÀ ĐĂNG NHẬP (AUTHENTICATION FLOW)

### Bước 1.1: Đăng ký tài khoản mới (Register)
- **Endpoint:** `POST /api/auth/register`
- **Auth Required:** No
- **Mô tả:** Đăng ký tài khoản Customer mới trên app.
- **Request Body (JSON):**
  ```json
  {
    "username": "nguyenvana",
    "email": "nguyenvana@gmail.com",
    "password": "Password123!",
    "fullName": "Nguyễn Văn A",
    "phoneNumber": "0987654321"
  }
  ```
- **Response (200 OK):**
  ```json
  {
    "message": "Đăng ký thành công."
  }
  ```

### Bước 1.2: Đăng nhập (Login)
- **Endpoint:** `POST /api/auth/login`
- **Auth Required:** No
- **Mô tả:** Đăng nhập để nhận Token xác thực. Token này sẽ được lưu ở `SharedPreferences` hoặc `Flutter Secure Storage` để dùng cho các bước sau.
- **Request Body (JSON):**
  ```json
  {
    "identifier": "nguyenvana", // Hoặc email / số điện thoại
    "password": "Password123!"
  }
  ```
- **Response (200 OK):**
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiIsInR...",
    "refreshToken": "abcdef123456...",
    "user": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "username": "nguyenvana",
      "email": "nguyenvana@gmail.com",
      "fullName": "Nguyễn Văn A",
      "phoneNumber": "0987654321",
      "roles": ["Customer"],
      "isActive": true
    }
  }
  ```

---

## 📦 LUỒNG 2: XEM TỦ KHÓA VÀ TRẠNG THÁI (LOCKERS FLOW)

### Bước 2.1: Lấy danh sách các tủ khóa (Get All Lockers)
- **Endpoint:** `GET /api/lockers`
- **Auth Required:** Yes
- **Mô tả:** Dùng để vẽ danh sách các cơ sở tủ khóa (Ví dụ: Tủ Quận 1, Tủ Quận 7) trên bản đồ hoặc danh sách.
- **Response (200 OK):**
  ```json
  [
    {
      "id": "...",
      "name": "Tủ khóa chi nhánh Quận 1",
      "location": "Tòa nhà Bitexco...",
      "isActive": true,
      "totalBoxes": 20
    }
  ]
  ```

### Bước 2.2: Xem chi tiết các ngăn tủ bên trong (Get Locker Boxes)
- **Endpoint:** `GET /api/lockers/{id}/boxes`
- **Auth Required:** Yes
- **Mô tả:** Hiển thị sơ đồ các ngăn tủ lớn/nhỏ và trạng thái (trống, đang bận) để user chọn ngăn.
- **Response (200 OK):**
  ```json
  [
    {
      "id": "...",
      "lockerId": "...",
      "boxNumber": 1,
      "size": 1, // 0: Small, 1: Medium, 2: Large
      "status": 0 // 0: Available, 1: InUse, 2: Maintenance
    }
  ]
  ```

---

## 💸 LUỒNG 3: NẠP TIỀN VÀ THANH TOÁN (WALLET & PAYMENT FLOW)

### Bước 3.1: Xem số dư ví
- **Endpoint:** `GET /api/wallet/balance`
- **Auth Required:** Yes
- **Response (200 OK):**
  ```json
  {
    "balance": 500000,
    "currency": "VND"
  }
  ```

### Bước 3.2: Nạp tiền vào ví
- **Endpoint:** `POST /api/wallet/top-up`
- **Auth Required:** Yes
- **Request Body:**
  ```json
  {
    "amount": 100000,
    "paymentMethod": "VNPay"
  }
  ```
- **Response (200 OK):** Trả về URL để WebView trên Flutter mở lên cho khách thanh toán VNPay/Momo.

---

## 🛒 LUỒNG 4: TẠO ĐƠN GỬI ĐỒ / ĐẶT NGĂN TỦ (BOOKINGS & ORDERS FLOW)

### Bước 4.1: Tạo đơn gửi đồ (Create Order)
- **Endpoint:** `POST /api/orders`
- **Auth Required:** Yes
- **Mô tả:** Khách hàng tiến hành thuê 1 ngăn tủ và lưu trữ gói hàng.
- **Request Body (JSON):**
  ```json
  {
    "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "lockerId": "c8a5... (ID của tủ)",
    "slotIndex": 1, // Số thứ tự ngăn tủ
    "packageId": "d7b2... (ID gói hàng nếu có, hoặc tạo mới)",
    "checkInTime": "2026-06-05T15:00:00Z",
    "durationHours": 4, // Thuê trong 4 tiếng
    "mobileNumber": "0987654321", // SĐT người nhận
    "notes": "Hàng dễ vỡ xin nhẹ tay"
  }
  ```
- **Response (200 OK):** Trả về thông tin Order và mã PIN để mở tủ.
  ```json
  {
    "orderId": "...",
    "lockerId": "...",
    "slotIndex": 1,
    "totalAmount": 20000,
    "pinCode": "123456", // QUAN TRỌNG: Mã PIN dùng để nhập trên tủ vật lý
    "status": "Created"
  }
  ```

### Bước 4.2: Thanh toán cho đơn (Pay Order)
- **Endpoint:** `POST /api/payments/pay`
- **Auth Required:** Yes
- **Mô tả:** Trừ tiền trong ví để thanh toán cho Order vừa tạo.
- **Request Body (JSON):**
  ```json
  {
    "orderId": "...",
    "amount": 20000,
    "paymentMethod": "Wallet" // Thanh toán qua ví nội bộ
  }
  ```

---

## 🔓 LUỒNG 5: TƯƠNG TÁC VỚI TỦ VẬT LÝ (LOCKER ACTIONS)

### Bước 5.1: Mở tủ từ xa qua App (Remote Open)
- **Endpoint:** `POST /api/lockers/{id}/boxes/{boxId}/open`
- **Auth Required:** Yes
- **Mô tả:** Nhấn nút "Mở tủ" trên màn hình Flutter, backend sẽ bắn tín hiệu xuống Tủ IoT qua MQTT/SignalR để bật chốt cửa sổ.
- **Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Đã gửi lệnh mở tủ thành công."
  }
  ```

### Bước 5.2: Hủy đơn hoặc Trả tủ (Cancel / Complete)
- **Endpoint:** `PUT /api/orders/{id}/complete`
- **Auth Required:** Yes
- **Mô tả:** Sau khi lấy đồ xong, bấm hoàn thành để hệ thống giải phóng ngăn tủ (Available).
- **Response (200 OK):**
  ```json
  {
    "success": true
  }
  ```

---

## 📱 LỜI KHUYÊN CHO TEAM FLUTTER (TIPS)
1. Hãy dùng thư viện `Dio` (có Interceptor) để tự động đính kèm `Authorization: Bearer Token` vào Header của mỗi Request.
2. Bắt lỗi `401 Unauthorized` trong Interceptor: Nếu Token hết hạn, tự động gọi API Refresh Token, sau đó gọi lại API bị tạch trước đó.
3. Phần "Mở tủ" từ xa nên làm nút nhấn có Loading Indicator, vì lệnh gửi MQTT xuống thiết bị IoT có thể mất từ 1-3 giây.
4. Với `Date` / `Time`, luôn dùng định dạng ISO 8601 UTC (`yyyy-MM-ddTHH:mm:ssZ`) để tránh lệch múi giờ giữa App và Backend.
