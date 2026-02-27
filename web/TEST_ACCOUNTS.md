# 🔐 Tài khoản test — LuxeLock Frontend

> File này chỉ dùng cho **frontend mock testing**.  
> Không dùng các tài khoản này trên môi trường backend thật.

---

## 👤 Role: User

| Username       | Email                | Password   | Ghi chú                                                        |
| -------------- | -------------------- | ---------- | -------------------------------------------------------------- |
| `nguyen_van_a` | nguyenvana@gmail.com | `User@123` | ✅ Bình thường, có nhiều booking (Active, Completed, Canceled) |
| `tran_thi_b`   | tranthib@gmail.com   | `User@123` | ✅ Bình thường, có booking Active & Completed                  |
| `le_van_c`     | levanc@gmail.com     | `User@123` | ⚠️ Email chưa xác minh → sẽ bị chặn đăng nhập                  |
| `pham_thi_d`   | phamthid@gmail.com   | `User@123` | ✅ Bình thường, có booking Active & Completed                  |
| `hoang_van_e`  | hoangvane@gmail.com  | `User@123` | 🔒 Tài khoản bị khóa (isActive = false)                        |
| `vo_thi_f`     | vothif@gmail.com     | `User@123` | ✅ Bình thường, có booking Active                              |
| `dang_van_g`   | dangvang@gmail.com   | `User@123` | ✅ Bình thường, có booking Active & Expired                    |
| `bui_thi_h`    | buithih@gmail.com    | `User@123` | ⚠️ Email chưa xác minh → sẽ bị chặn đăng nhập                  |
| `do_van_i`     | dovani@gmail.com     | `User@123` | ✅ Bình thường, có booking Pending & Completed                 |
| `ngo_thi_k`    | ngothik@gmail.com    | `User@123` | ✅ Bình thường, có booking Active & Canceled                   |

---

## 🛡️ Role: Admin

| Username       | Email                    | Password    | Ghi chú                                 |
| -------------- | ------------------------ | ----------- | --------------------------------------- |
| `admin_hoai`   | admin.hoai@luxelock.vn   | `Admin@123` | ✅ Bình thường                          |
| `admin_minh`   | admin.minh@luxelock.vn   | `Admin@123` | ✅ Bình thường                          |
| `admin_linh`   | admin.linh@luxelock.vn   | `Admin@123` | ✅ Bình thường                          |
| `admin_tuan`   | admin.tuan@luxelock.vn   | `Admin@123` | 🔒 Tài khoản bị khóa (isActive = false) |
| `admin_phuong` | admin.phuong@luxelock.vn | `Admin@123` | ✅ Bình thường                          |

---

## 🚚 Role: Shipper

| Username       | Email                    | Password      | Ghi chú                                 |
| -------------- | ------------------------ | ------------- | --------------------------------------- |
| `shipper_nam`  | shipper.nam@luxelock.vn  | `Shipper@123` | ✅ Bình thường                          |
| `shipper_hung` | shipper.hung@luxelock.vn | `Shipper@123` | ✅ Bình thường                          |
| `shipper_lan`  | shipper.lan@luxelock.vn  | `Shipper@123` | ✅ Bình thường                          |
| `shipper_phuc` | shipper.phuc@luxelock.vn | `Shipper@123` | 🔒 Tài khoản bị khóa (isActive = false) |
| `shipper_mai`  | shipper.mai@luxelock.vn  | `Shipper@123` | ✅ Bình thường                          |

---

## 🧪 Test cases gợi ý

| Kịch bản                | Dùng tài khoản                      | Kết quả mong đợi                                   |
| ----------------------- | ----------------------------------- | -------------------------------------------------- |
| Đăng nhập thành công    | `nguyen_van_a` / `User@123`         | Vào trang `/lockers`                               |
| Sai mật khẩu            | `nguyen_van_a` / `wrongpass`        | Hiện lỗi "Mật khẩu không chính xác."               |
| Tài khoản không tồn tại | `ghost_user` / bất kỳ               | Hiện lỗi "Tên đăng nhập hoặc email không tồn tại." |
| Tài khoản bị khóa       | `hoang_van_e` / `User@123`          | Hiện lỗi "Tài khoản của bạn đã bị khóa."           |
| Email chưa xác minh     | `le_van_c` / `User@123`             | Hiện lỗi "Email chưa được xác minh..."             |
| Đăng nhập bằng email    | `nguyenvana@gmail.com` / `User@123` | Vào trang `/lockers`                               |
| Xem booking Pending     | `do_van_i` / `User@123`             | Trang bookings có tab Chờ PIN                      |
| Xem booking Expired     | `dang_van_g` / `User@123`           | Trang bookings có tab Hết hạn                      |
| Admin login             | `admin_hoai` / `Admin@123`          | Đăng nhập được, role = Admin                       |
| Shipper login           | `shipper_nam` / `Shipper@123`       | Đăng nhập được, role = Shipper                     |

---

## 📦 Booking đặc biệt để test chi tiết

| Booking ID | User         | Trạng thái                                       | URL                |
| ---------- | ------------ | ------------------------------------------------ | ------------------ |
| `bk-001`   | nguyen_van_a | **Active** — có thể Verify PIN, Complete, Cancel | `/bookings/bk-001` |
| `bk-003`   | le_van_c     | **Pending** — có thể Set PIN, Cancel             | `/bookings/bk-003` |
| `bk-002`   | tran_thi_b   | **Completed** — chỉ xem                          | `/bookings/bk-002` |
| `bk-004`   | nguyen_van_a | **Canceled** — chỉ xem                           | `/bookings/bk-004` |
| `bk-006`   | hoang_van_e  | **Expired** — chỉ xem                            | `/bookings/bk-006` |
