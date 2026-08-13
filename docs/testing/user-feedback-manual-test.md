# Checklist nghiệm thu thủ công — User Feedback

> Đây là **mẫu checklist**, không phải biên bản đã chạy. Mọi ô `Actual`, `Kết quả`, `Trạng thái` và `Bằng chứng` phải được người thực hiện điền sau khi kiểm thử trong môi trường được phê duyệt.

## Thông tin lượt chạy

| Trường | Giá trị |
| --- | --- |
| Người thực hiện | ____________________ |
| Môi trường / URL | ____________________ |
| Ngày giờ bắt đầu (ICT) | ____________________ |
| Ngày giờ kết thúc (ICT) | ____________________ |
| Commit SHA tham chiếu | ____________________ |
| Phiên bản backend / web | ____________________ |
| Trạng thái tổng thể | Chưa chạy |
| Thư mục bằng chứng đã được phê duyệt | ____________________ |

## Nguyên tắc bảo mật bằng chứng

- Không ghi mật khẩu, token, email, cookie, chuỗi kết nối, ảnh chụp chứa dữ liệu nhạy cảm, hoặc thông tin định danh cá nhân vào tài liệu này hay repository.
- Chỉ dùng nhãn tài khoản `user-01` đến `user-10`; không thay thế nhãn bằng dữ liệu thật.
- Đính kèm tên tệp ảnh chụp hoặc mã tham chiếu trong kho bằng chứng được phê duyệt. Không commit bằng chứng có dữ liệu cá nhân.
- Nếu một bước không thể thực hiện, giữ `Trạng thái` là `Chưa chạy` và mô tả lý do trong ô `Actual`; không suy diễn kết quả.

## Điều kiện tiên quyết

| Mục | Điều kiện cần có | Xác nhận / ghi chú | Trạng thái |
| --- | --- | --- | --- |
| P1 | Môi trường backend, web và MongoDB thật đã được phê duyệt, đang sẵn sàng. |  | Chưa chạy |
| P2 | Có 10 tài khoản người dùng thật, riêng biệt, được quản lý ngoài tài liệu này. |  | Chưa chạy |
| P3 | Có một tài khoản quản trị hợp lệ để dùng dashboard/moderation. |  | Chưa chạy |
| P4 | Người thực hiện có quyền xem dữ liệu MongoDB và xuất CSV trong đúng môi trường. |  | Chưa chạy |
| P5 | Có trình duyệt desktop và thiết bị hoặc mô phỏng mobile hợp lệ. |  | Chưa chạy |
| P6 | Đã xác định nơi lưu ảnh chụp/bằng chứng theo chính sách bảo mật. |  | Chưa chạy |

## 1. Build sản phẩm

Chạy từng lệnh từ thư mục gốc repository. Không dán đầu ra có secret vào tài liệu.

```powershell
dotnet build backend/Locker.Backend.sln -c Release -m:1
Push-Location web
npm.cmd run build
Pop-Location
```

| Lệnh | Expected | Actual | Trạng thái | Bằng chứng |
| --- | --- | --- | --- | --- |
| `dotnet build backend/Locker.Backend.sln -c Release -m:1` | Exit code `0`, build Release thành công. |  | Chưa chạy |  |
| `npm.cmd run build` (trong `web`) | Exit code `0`, build web thành công. |  | Chưa chạy |  |

## 2. Vòng đời feedback của một người dùng

Đăng nhập bằng `user-01`; ghi lại ID feedback ở dạng tham chiếu nội bộ không nhạy cảm nếu chính sách cho phép.

| Ca kiểm tra | Expected | Actual | Trạng thái | Bằng chứng |
| --- | --- | --- | --- | --- |
| Tuyến authenticated | Nút E-box/feedback xuất hiện ở các tuyến yêu cầu đăng nhập đã thiết kế. |  | Chưa chạy |  |
| Tuyến public/anonymous | Nút không xuất hiện ở các tuyến public hoặc khi chưa đăng nhập. |  | Chưa chạy |  |
| Gửi lần đầu | Tạo feedback thành công; phản hồi chứa một feedback ID. |  | Chưa chạy |  |
| Gửi/cập nhật lần sau | Cập nhật feedback của chính `user-01`; feedback ID không đổi. |  | Chưa chạy |  |
| MongoDB của `user-01` | Có đúng một document feedback theo `userId` của tài khoản này. |  | Chưa chạy |  |
| Backend không khả dụng | Giao diện báo lỗi phù hợp, không báo thành công giả. |  | Chưa chạy |  |
| Thử lại sau khi backend hoạt động | Có thể gửi/cập nhật thành công theo hành vi dự kiến. |  | Chưa chạy |  |

## 3. API: validation và authorization

Dùng Swagger hoặc API client trên backend đang chạy. Ghi status quan sát được, không ghi Authorization header, token hay payload có dữ liệu cá nhân.

| Ca kiểm tra | Expected | Actual HTTP status / ghi chú | Trạng thái | Bằng chứng |
| --- | --- | --- | --- | --- |
| Rating không hợp lệ | `400` |  | Chưa chạy |  |
| Topic không hợp lệ | `400` |  | Chưa chạy |  |
| Content rỗng | `400` |  | Chưa chạy |  |
| Content dài 2.001 ký tự | `400` |  | Chưa chạy |  |
| `pageUrl` không an toàn | `400` |  | Chưa chạy |  |
| Route cần đăng nhập, không có token | `401` |  | Chưa chạy |  |
| Route quản trị với user token thường | `403` |  | Chưa chạy |  |
| Visibility ID không tồn tại | `404` |  | Chưa chạy |  |

## 4. Mười người dùng riêng biệt và dashboard progress

Thực hiện thao tác qua E-box UI bằng 10 tài khoản thật. Chỉ điền nhãn, rating, topic và thời điểm; không điền email, mật khẩu hay token.

| Tài khoản | Rating | Topic | Thời điểm gửi (ICT) | Feedback ID tham chiếu | Trạng thái | Bằng chứng |
| --- | --- | --- | --- | --- | --- | --- |
| user-01 |  |  |  |  | Chưa chạy |  |
| user-02 |  |  |  |  | Chưa chạy |  |
| user-03 |  |  |  |  | Chưa chạy |  |
| user-04 |  |  |  |  | Chưa chạy |  |
| user-05 |  |  |  |  | Chưa chạy |  |
| user-06 |  |  |  |  | Chưa chạy |  |
| user-07 |  |  |  |  | Chưa chạy |  |
| user-08 |  |  |  |  | Chưa chạy |  |
| user-09 |  |  |  |  | Chưa chạy |  |
| user-10 |  |  |  |  | Chưa chạy |  |

Trong Mongo shell, chạy truy vấn sau trên database/môi trường đã được phê duyệt:

```javascript
db.feedbacks.aggregate([
  { $group: { _id: "$userId", count: { $sum: 1 } } },
  { $group: { _id: null, distinctUsers: { $sum: 1 }, duplicateUsers: { $sum: { $cond: [{ $gt: ["$count", 1] }, 1, 0] } } } }
])
```

| Kiểm tra | Expected | Actual | Trạng thái | Bằng chứng |
| --- | --- | --- | --- | --- |
| Tổng hợp distinct users | `distinctUsers >= 10` và `duplicateUsers = 0`. |  | Chưa chạy |  |
| Dashboard progress | Progress hiển thị ít nhất `10/10`. |  | Chưa chạy |  |

## 5. Kiểm tra MongoDB index và tính duy nhất

Chạy các lệnh chỉ-đọc sau trong Mongo shell trên môi trường đã được phê duyệt. Ghi tên/index key quan sát được, không ghi URI kết nối.

```javascript
db.feedbacks.getIndexes()
db.feedbacks.aggregate([
  { $group: { _id: "$userId", count: { $sum: 1 } } },
  { $match: { count: { $gt: 1 } } }
])
```

| Kiểm tra | Expected | Actual | Trạng thái | Bằng chứng |
| --- | --- | --- | --- | --- |
| Index collection feedbacks | Index hỗ trợ ràng buộc/hành vi một feedback trên một `userId` theo thiết kế triển khai. |  | Chưa chạy |  |
| Aggregate user trùng | Không có dòng `userId` với `count > 1` sau bộ dữ liệu nghiệm thu. |  | Chưa chạy |  |

## 6. Bất biến moderation

Chọn một review thật đã được phê duyệt để kiểm tra; chỉ dùng nhãn tham chiếu không nhạy cảm.

| Ca kiểm tra | Expected | Actual | Trạng thái | Bằng chứng |
| --- | --- | --- | --- | --- |
| Hide review | Review biến mất khỏi phần review công khai trên trang chủ. |  | Chưa chạy |  |
| Progress sau hide | Admin progress không thay đổi. |  | Chưa chạy |  |
| Owner cập nhật review đang hidden | Review vẫn hidden sau khi chủ sở hữu cập nhật. |  | Chưa chạy |  |
| Show review | Review xuất hiện lại ở phần công khai. |  | Chưa chạy |  |

## 7. Filters, pagination, CSV, responsive và accessibility

| Ca kiểm tra | Expected | Actual | Trạng thái | Bằng chứng |
| --- | --- | --- | --- | --- |
| Mỗi filter riêng lẻ | Mỗi filter trả đúng tập kết quả tương ứng. |  | Chưa chạy |  |
| Combined filters | Kết quả thỏa tất cả filter đã chọn. |  | Chưa chạy |  |
| Search | Kết quả phù hợp từ khóa; trạng thái rỗng rõ ràng khi không có kết quả. |  | Chưa chạy |  |
| Previous pagination | Không chuyển vượt trang đầu; dữ liệu trang trước đúng. |  | Chưa chạy |  |
| Next pagination | Không chuyển vượt trang cuối; dữ liệu trang sau đúng. |  | Chưa chạy |  |
| CSV theo filter | Số dòng CSV khớp số bản ghi của filter đang áp dụng (trừ header). |  | Chưa chạy |  |
| Tiếng Việt trong Excel | Văn bản tiếng Việt hiển thị đúng khi mở CSV bằng Excel. |  | Chưa chạy |  |
| Formula injection | Nội dung bắt đầu bằng `=`, `+`, `-` hoặc `@` hiển thị là text trong Excel, không được thực thi như công thức. |  | Chưa chạy |  |
| Desktop | Giao diện dashboard/public review không vỡ tại viewport desktop đã chọn. |  | Chưa chạy |  |
| Mobile | Giao diện sử dụng được, không che nút/chức năng tại viewport mobile đã chọn. |  | Chưa chạy |  |
| Keyboard | Điều hướng bàn phím tới các control chính theo thứ tự hợp lý, focus nhận biết được. |  | Chưa chạy |  |
| Screen reader/semantics | Nhãn, tên control và thông báo lỗi/trạng thái có thể nhận biết bằng công cụ trợ năng đã chọn. |  | Chưa chạy |  |

## 8. Kiểm tra repository trước khi commit biên bản đã điền

Sau khi hoàn tất các bước thủ công, chạy từ thư mục gốc repository:

```powershell
dotnet build backend/Locker.Backend.sln -c Release -m:1
Push-Location web
npm.cmd run build
Pop-Location
git diff --check
git status --short
```

| Kiểm tra | Expected | Actual | Trạng thái | Bằng chứng |
| --- | --- | --- | --- | --- |
| Release build backend | Exit code `0`. |  | Chưa chạy |  |
| Production build web | Exit code `0`. |  | Chưa chạy |  |
| `git diff --check` | Không có lỗi whitespace. |  | Chưa chạy |  |
| `git status --short` | Trước commit, chỉ có thay đổi biên bản/bằng chứng được phép; kiểm tra không có secret. |  | Chưa chạy |  |

## Quyết định nghiệm thu

| Hạng mục | Kết luận | Ghi chú |
| --- | --- | --- |
| Build | Chưa chạy |  |
| Vòng đời và API | Chưa chạy |  |
| 10 người dùng/MongoDB | Chưa chạy |  |
| Moderation | Chưa chạy |  |
| Dashboard/CSV/responsive/accessibility | Chưa chạy |  |
| Nghiệm thu tổng thể | Chưa chạy |  |

Khi checklist đã được điền và được người có thẩm quyền phê duyệt, có thể kiểm tra khác biệt rồi commit:

```powershell
git diff --check
git add docs/testing/user-feedback-manual-test.md
git commit -m "docs: add manual feedback verification checklist"
```
