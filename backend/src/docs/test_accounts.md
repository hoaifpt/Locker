# Locker API - Test Accounts

Dưới đây là danh sách tổng hợp toàn bộ các tài khoản đã được hệ thống tạo sẵn (seed) vào cơ sở dữ liệu. Bạn có thể sử dụng Username, Email hoặc Số điện thoại để đăng nhập trên Swagger UI (Endpoint: `/api/auth/login`).

> [!TIP]
> **Hướng dẫn Test trên Swagger:**
> 1. Gọi API `POST /api/auth/login` với thông tin của một tài khoản dưới đây (nhập vào mục `Identifier` là Username, Email, hoặc Số điện thoại).
> 2. Copy chuỗi `token` trả về.
> 3. Kéo lên đầu trang Swagger, bấm nút **Authorize**, dán token vừa copy vào (Lưu ý: Không nhập chữ "Bearer", chỉ nhập nội dung token).
> 4. Nhấn Authorize và bắt đầu test các luồng API tương ứng với Role của tài khoản đó.

---

## 1. Quản Trị Viên (Admin)
Tài khoản có toàn quyền truy cập để quản lý Tủ khoá, Package, và các báo cáo hệ thống.

| Họ Tên | Identifier (Username / Email) | Password | SĐT |
| :--- | :--- | :--- | :--- |
| Administrator | `admin` <br> `admin@locker.com` | `Admin123` | `0000000000` |

---

## 2. Khách Hàng (Customer)
Dùng để test luồng: Book tủ cá nhân, Mua gói lưu trữ, Gửi hàng, Đặt đồ ăn (FoodOrder), Nạp tiền ví, v.v.

**Mật khẩu chung cho tất cả Customers:** `User123`

| Họ Tên | Username | Email | Số điện thoại |
| :--- | :--- | :--- | :--- |
| Nguyễn Văn An | `nguyenvanan` | `nguyenvanan@gmail.com` | `0901234567` |
| Trần Thị Mai | `tranthimai` | `tranthimai@gmail.com` | `0912345678` |
| Lê Hoàng Tuấn | `lehoangtuan` | `lehoangtuan@gmail.com` | `0923456789` |
| Phạm Ngọc Bích | `phamngocbich` | `phamngocbich@gmail.com` | `0934567890` |
| Vũ Xuân Đạt | `vuxuandat` | `vuxuandat@gmail.com` | `0945678901` |

> [!NOTE]
> Khách hàng đã được nạp sẵn `1.000.000 VNĐ` vào ví ảo (Wallet) để tiện cho việc test thanh toán.

---

## 3. Người Giao Hàng (Shipper)
Dùng để test luồng: Giao bưu kiện (DeliveryRequest), Thao tác đóng/mở khoang tủ để cất hàng.

**Mật khẩu chung cho tất cả Shippers:** `User123`

| Họ Tên | Username | Email | Số điện thoại |
| :--- | :--- | :--- | :--- |
| Đinh Văn Giao | `dinhvangiao` | `dinhvangiao@fastdelivery.com` | `0812345678` |
| Lý Thanh Hải | `lythanhhai` | `lythanhhai@fastdelivery.com` | `0823456789` |
| Bùi Trọng Hiếu | `buitronghieu` | `buitronghieu@fastdelivery.com` | `0834567890` |
| Đỗ Văn Toàn | `dovantoan` | `dovantoan@fastdelivery.com` | `0845678901` |

---

> [!IMPORTANT]
> Các tài khoản này sẽ tự động được làm mới (cập nhật lại mật khẩu và thông tin) mỗi khi dự án khởi động lại. Nếu bạn cố tình đổi mật khẩu thông qua tính năng Reset Password, hãy nhớ rằng lần khởi động server tiếp theo mật khẩu sẽ bị reset về mặc định như trên.
