# User Feedback Design

## Mục tiêu

Xây dựng tính năng đánh giá trực tiếp trong nền tảng E-box để thu thập và chứng minh tối thiểu 10 người dùng khác nhau đã gửi feedback mà không dùng Google Form. Người dùng đã đăng nhập gửi hoặc cập nhật một feedback duy nhất; review được công khai ngay bằng username. Admin theo dõi tiến độ, thống kê, xuất CSV và có thể ẩn hoặc hiện lại nội dung không phù hợp.

## Phạm vi

Tính năng bao gồm:

- Nút `Feedback` nhỏ dạng pill, cố định ở góc dưới bên phải trên mọi trang sau đăng nhập.
- Modal tạo hoặc cập nhật feedback.
- API và MongoDB collection lưu feedback.
- Section `Người dùng nói gì` trên trang chủ.
- Dashboard admin có thống kê, lọc, phân trang, xuất CSV và điều khiển trạng thái hiển thị.
- Checklist kiểm thử thủ công bằng tài khoản thật, API thật và MongoDB thật.

Không nằm trong phạm vi:

- Người dùng chưa đăng nhập gửi feedback.
- Quy trình duyệt trước khi review được công khai.
- Xóa vĩnh viễn feedback.
- Nhiều feedback hoặc lịch sử phiên bản feedback cho cùng một người dùng.
- Unit test, integration test, UI automation test hoặc mock test.

## Trải nghiệm người dùng

### Nút và modal feedback

`FeedbackButton` được render trong vùng giao diện dùng chung của các trang đã đăng nhập. Nút có chữ `Feedback`, kích thước nhỏ, dạng pill và cố định ở góc dưới bên phải. Nút không xuất hiện trên trang chủ công khai hoặc các trang đăng nhập, đăng ký và khôi phục tài khoản.

Khi bấm nút, `FeedbackModal` mở và gọi API lấy feedback hiện tại. Nếu đã có dữ liệu, form được điền sẵn để chỉnh sửa. Nếu chưa có, form bắt đầu ở trạng thái trống. Trong lúc tải, modal hiển thị trạng thái loading. Nếu tải thất bại, modal báo lỗi và không hiển thị một form trống có thể khiến người dùng tưởng rằng dữ liệu cũ không tồn tại.

Form gồm:

- `Rating`: bắt buộc, số nguyên từ 1 đến 5, nhập bằng dãy nút hình sao có nhãn truy cập.
- `Topic`: bắt buộc, một trong `General`, `BookingOrder`, `Payment`, `Delivery`, `Interface`, `Other`.
- `Content`: bắt buộc sau khi trim, tối đa 2.000 ký tự, có bộ đếm ký tự.
- `PageUrl`: hệ thống tự lấy pathname hiện tại; không đưa token, fragment hoặc query string vào dữ liệu gửi đi.

Nút gửi bị khóa khi request đang chạy. Khi thành công, modal đóng và toast xác nhận được hiển thị. Khi thất bại, thông báo lỗi xuất hiện nhưng dữ liệu đang nhập được giữ nguyên. Modal hỗ trợ đóng bằng nút đóng, phím `Escape`, quản lý focus và trả focus về nút mở sau khi đóng.

### Quy tắc một feedback cho mỗi người

Mỗi `UserId` chỉ có một feedback. Lần gửi đầu tạo bản ghi; các lần tiếp theo cập nhật bản ghi đó và `UpdatedAt`, không tăng số người đã feedback. Nếu feedback đang bị ẩn, người dùng vẫn được sửa nhưng việc sửa không tự chuyển `IsVisible` về `true`.

### Review công khai

Section `Người dùng nói gì` trên trang chủ hiển thị:

- Điểm trung bình của các review đang hiển thị.
- Tổng số người có review đang hiển thị.
- Tối đa 6 review đang hiển thị, sắp xếp theo `UpdatedAt` mới nhất.
- Username, số sao, chủ đề, nội dung và ngày cập nhật của từng review.

Không trả hoặc hiển thị `UserId`, email hay dữ liệu quản trị. Nội dung được render dưới dạng text thuần. Review được công khai ngay khi người dùng gửi lần đầu, không cần admin duyệt.

## Dashboard admin

Dashboard đặt tại route được bảo vệ dành riêng cho role `Admin`. Trang gồm:

- Thẻ tiến độ `Đã có x/10 người dùng đánh giá`; trạng thái đổi sang hoàn thành khi `x >= 10`.
- Tổng số người đã feedback, điểm trung bình và số review đang hiển thị.
- Phân bố số lượng review theo 1–5 sao.
- Phân bố số lượng review theo chủ đề.
- Bảng có username, rating, chủ đề, nội dung, page URL, ngày tạo, ngày cập nhật và trạng thái hiển thị.
- Bộ lọc theo rating, topic và trạng thái hiển thị.
- Tìm kiếm không phân biệt hoa thường theo username hoặc nội dung.
- Phân trang phía server.
- Hành động ẩn hoặc hiện lại review; không có xóa vĩnh viễn.
- Xuất CSV theo đúng bộ lọc và tìm kiếm hiện tại.

Chỉ admin được truy cập danh sách đầy đủ, thống kê quản trị, CSV và endpoint thay đổi trạng thái. Việc ẩn review chỉ loại review khỏi dữ liệu công khai; bản ghi vẫn tồn tại và vẫn được tính là một người đã feedback trong tiến độ `x/10` phục vụ minh chứng thu thập.

## Kiến trúc backend

Module tuân theo kiến trúc hiện có của backend:

- Domain: entity `Feedback` và enum `FeedbackTopic`.
- Application: model request/response, `IFeedbackRepository`, MediatR commands và queries.
- Infrastructure: `FeedbackRepository` sử dụng MongoDB và đăng ký dependency injection.
- API: `FeedbacksController` cho API người dùng/public; các API quản trị đặt dưới route `/api/admin/feedbacks` và yêu cầu role `Admin`.

### Mô hình `Feedback`

| Trường | Kiểu | Quy tắc |
| --- | --- | --- |
| `Id` | `Guid` | ID bản ghi |
| `UserId` | `Guid` | Bắt buộc, duy nhất |
| `Username` | `string` | Snapshot tên hiển thị lúc lưu/cập nhật |
| `Rating` | `int` | Số nguyên 1–5 |
| `Topic` | `FeedbackTopic` | Một giá trị enum hợp lệ |
| `Content` | `string` | Trim, bắt buộc, tối đa 2.000 ký tự |
| `PageUrl` | `string` | Chỉ pathname nội bộ, tối đa 500 ký tự |
| `IsVisible` | `bool` | Mặc định `true` khi tạo mới |
| `CreatedAt` | `DateTime` | UTC, không đổi khi cập nhật |
| `UpdatedAt` | `DateTime` | UTC, cập nhật mỗi lần người dùng sửa |

`Username` được lấy từ user record hiện tại ở server, không nhận từ request. Việc dùng snapshot giúp review vẫn có tên hiển thị ổn định; khi người dùng cập nhật feedback, snapshot được làm mới theo username hiện tại.

MongoDB dùng collection `feedbacks`. `MongoSettings` bổ sung tên collection và `MongoContext` tạo unique index tăng dần trên `UserId`. Repository thực hiện atomic upsert theo `UserId` để các request đồng thời không tạo hai bản ghi. Khi cập nhật từ phía người dùng, câu lệnh chỉ sửa `Username`, `Rating`, `Topic`, `Content`, `PageUrl` và `UpdatedAt`, không sửa `IsVisible` hoặc `CreatedAt`.

## Hợp đồng API

### API người dùng

`GET /api/feedbacks/me`

- Yêu cầu đăng nhập.
- Trả `200` với feedback hiện tại hoặc `204` nếu chưa gửi.

`PUT /api/feedbacks/me`

- Yêu cầu đăng nhập.
- Body gồm `rating`, `topic`, `content`, `pageUrl`.
- Tạo hoặc cập nhật atomic theo `UserId`.
- Trả `200` với feedback đã lưu.

### API công khai

`GET /api/feedbacks/public?limit=6`

- Không yêu cầu đăng nhập.
- `limit` mặc định và tối đa là 6 cho section trang chủ.
- Chỉ lấy `IsVisible = true`, sắp xếp `UpdatedAt` giảm dần.
- Trả `averageRating`, `totalVisibleReviewers` và danh sách review an toàn cho public.

### API admin

`GET /api/admin/feedbacks?page=1&pageSize=20&rating=&topic=&visibility=&search=`

- Yêu cầu role `Admin`.
- `pageSize` mặc định 20, tối đa 100.
- Trả danh sách phân trang và summary gồm tổng người feedback, điểm trung bình, tổng review hiển thị, phân bố rating và phân bố topic.
- Thống kê tổng hợp phản ánh toàn bộ tập dữ liệu phù hợp bộ lọc, không chỉ trang hiện tại. Tiến độ `x/10` luôn lấy tổng số `UserId` có feedback, không bị ảnh hưởng bởi bộ lọc giao diện hoặc `IsVisible`.

`PATCH /api/admin/feedbacks/{id}/visibility`

- Yêu cầu role `Admin`.
- Body `{ "isVisible": true | false }`.
- Trả `204` khi thành công và `404` nếu không có feedback.

`GET /api/admin/feedbacks/export?rating=&topic=&visibility=&search=`

- Yêu cầu role `Admin`.
- Xuất toàn bộ bản ghi phù hợp bộ lọc, không phân trang.
- File CSV dùng UTF-8 BOM để Excel đọc đúng tiếng Việt.
- Các ô văn bản bắt đầu bằng `=`, `+`, `-` hoặc `@` được thêm dấu nháy đơn để chống CSV formula injection.

## Frontend structure

Frontend dùng React 18, TypeScript, Tailwind CSS, Framer Motion, Lucide và toast context hiện có. Các đơn vị được tách theo trách nhiệm:

- `FeedbackButton`: nút nổi và trạng thái mở/đóng.
- `FeedbackModal`: tải dữ liệu hiện tại, quản lý form, validation và submit.
- `StarRating`: input rating có keyboard và accessibility semantics.
- `PublicReviewsSection`: tải và render summary cùng review công khai trên trang chủ.
- `AdminFeedbackPage`: quản lý query state, filters, pagination, summary, bảng và xuất CSV.
- `feedbackApi`: hợp đồng gọi API và kiểu dữ liệu dùng chung trong frontend.

Nút được gắn ở cấp layout dùng chung của khu vực authenticated để tránh lặp lại trên từng page. Route admin mới được đặt dưới `ProtectedRoute` với `allowedRoles={['Admin']}`. Trang chủ công khai chỉ gắn `PublicReviewsSection`, không gắn nút gửi feedback.

## Validation, bảo mật và xử lý lỗi

- Frontend và backend cùng kiểm tra rating, topic, content và độ dài.
- Backend lấy `UserId` từ claim và username từ user store; không tin dữ liệu định danh từ client.
- `PageUrl` chỉ chấp nhận đường dẫn bắt đầu bằng `/`, không chứa query hoặc fragment, tối đa 500 ký tự.
- Public response không chứa ID người dùng hoặc email.
- Nội dung review được render bằng text binding của React, không dùng raw HTML.
- API admin bắt buộc role `Admin`; UI ẩn route không thay thế kiểm tra quyền ở backend.
- Validation lỗi trả `400`, chưa đăng nhập trả `401`, sai role trả `403`, không tìm thấy trả `404`.
- Frontend phân biệt lỗi tải, lỗi validation và lỗi gửi; không xóa nội dung người dùng khi request thất bại.
- Trạng thái loading ngăn gửi lặp và ngăn thao tác visibility lặp trên dashboard.

## Kiểm thử thủ công

Không tạo bất kỳ unit test, integration test, UI automation test hoặc mock test nào. Việc xác minh thực hiện trực tiếp với frontend, backend, MongoDB và tài khoản thật.

Checklist bắt buộc trước khi hoàn thành:

1. Build backend và web thành công.
2. Đăng nhập bằng user thường, xác nhận nút `Feedback` xuất hiện trên nhiều authenticated route và không xuất hiện ở public/auth route.
3. Kiểm tra modal bằng chuột và bàn phím: focus, chọn sao, `Escape`, validation và bộ đếm 2.000 ký tự.
4. Gửi feedback hợp lệ, xác nhận toast, section trang chủ và document MongoDB chứa đúng dữ liệu.
5. Mở lại modal, xác nhận dữ liệu cũ được tải; cập nhật feedback và xác nhận vẫn chỉ có một document cho `UserId` đó.
6. Thử rating/topic/content/page URL không hợp lệ trực tiếp qua API và xác nhận status `400`.
7. Gửi request không token và sai role tới API bảo vệ, xác nhận lần lượt `401` và `403`.
8. Dùng ít nhất 10 tài khoản user riêng biệt gửi feedback; xác nhận dashboard đạt `10/10` và số document/UserId riêng biệt là 10.
9. Cho một tài khoản sửa feedback nhiều lần; xác nhận tiến độ vẫn là `10/10`.
10. Kiểm tra tìm kiếm, từng filter, tổ hợp filter, pagination và các thống kê tương ứng.
11. Admin ẩn một review; xác nhận review biến mất khỏi trang chủ nhưng tiến độ thu thập không giảm. Hiện lại review và xác nhận review xuất hiện lại.
12. Người dùng cập nhật một review đang bị ẩn; xác nhận review vẫn bị ẩn.
13. Xuất CSV theo bộ lọc; mở bằng Excel để kiểm tra tiếng Việt, cột dữ liệu, số dòng và bảo vệ formula injection.
14. Kiểm tra responsive trên desktop và mobile; nút không che hành động quan trọng và modal không tràn viewport.

## Tiêu chí chấp nhận

- Chỉ user đã đăng nhập có thể tạo hoặc cập nhật feedback trực tiếp trên E-box.
- Mỗi `UserId` có đúng một feedback và được phép cập nhật.
- Review mới hiển thị công khai ngay với username, không cần duyệt trước.
- Admin có thể ẩn/hiện nhưng không xóa vĩnh viễn feedback.
- Trang chủ chỉ hiển thị review có `IsVisible = true`.
- Dashboard chứng minh chính xác số người dùng duy nhất đã feedback và thể hiện đạt yêu cầu khi có ít nhất 10 người.
- Admin có thể lọc, phân trang và xuất CSV an toàn để làm minh chứng.
- Không tạo test tự động hoặc mock; toàn bộ checklist kiểm thử thủ công được thực hiện và ghi nhận kết quả khi triển khai.
