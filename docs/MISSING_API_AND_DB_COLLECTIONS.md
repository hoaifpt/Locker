# Missing Backend APIs and MongoDB Collections

## Mục tiêu
Tài liệu này liệt kê các collection MongoDB mới đã tạo và các API backend tương ứng đang còn thiếu để kết nối đầy đủ với ứng dụng mobile.

## 1. Collection đã có / thêm
Các collection mới cần hỗ trợ trong backend:
- `wallet_transactions`
- `restaurants`
- `menu_items`
- `food_orders`
- `delivery_requests`
- `send_receive_orders`
- `qr_scans`
- `locker_events`
- `notifications`
- `device_tokens`

> Lưu ý: `users`, `lockers`, `packages`, `orders`, `bookings`, `payments`, `otp_codes`, `refresh_tokens` là các collection core hiện có.

## 2. API cần bổ sung cho mỗi collection

### 2.1 Wallet
- `GET /api/wallet/overview`
- `GET /api/wallet/transactions`
- `GET /api/wallet/balance`
- `POST /api/wallet/top-up`
- `POST /api/wallet/transfer`

### 2.2 Restaurants / Menu / Food Orders
- `GET /api/restaurants`
- `GET /api/restaurants/{id}`
- `GET /api/restaurants/{id}/menu`
- `GET /api/menu-items/{id}`
- `POST /api/food-orders`
- `GET /api/food-orders/my`
- `GET /api/food-orders/{id}`

### 2.3 Delivery Requests
- `GET /api/delivery/package-sizes`
- `POST /api/delivery/requests`
- `GET /api/delivery/requests/my`
- `GET /api/delivery/requests/{id}`
- `GET /api/delivery/requests/track/{trackingCode}`

### 2.4 Send/Receive Orders
- `POST /api/send-receive/orders`
- `GET /api/send-receive/orders/my`
- `GET /api/send-receive/orders/{id}`
- `PATCH /api/send-receive/orders/{id}/confirm`
- `PATCH /api/send-receive/orders/{id}/complete`

### 2.5 Locker Events
- `GET /api/lockers/{id}/events`
- `GET /api/lockers/{id}/slots/{slotIndex}/events`

### 2.6 Device Tokens
- `GET /api/device-tokens/my`
- `DELETE /api/device-tokens/{id}`

## 3. Gợi ý cấu trúc endpoint trong `ApiEndpoints.cs`

Có thể thêm các block mới như sau:

```csharp
public static class Wallet
{
    private const string Base = $"{ApiBase}/wallet";
    public const string Overview = $"{Base}/overview";
    public const string Transactions = $"{Base}/transactions";
    public const string Balance = $"{Base}/balance";
    public const string TopUp = Base;
    public const string Transfer = $"{Base}/transfer";
}

public static class Restaurants
{
    private const string Base = $"{ApiBase}/restaurants";
    public const string GetAll = Base;
    public const string GetById = $"{Base}/{{id}}";
    public const string GetMenu = $"{Base}/{{id}}/menu";
}

public static class FoodOrders
{
    private const string Base = $"{ApiBase}/food-orders";
    public const string Create = Base;
    public const string GetMy = $"{Base}/my";
    public const string GetById = $"{Base}/{{id}}";
}

public static class Delivery
{
    private const string Base = $"{ApiBase}/delivery";
    public const string GetPackageSizes = $"{Base}/package-sizes";
    public const string CreateRequest = $"{Base}/requests";
    public const string GetMyRequests = $"{Base}/requests/my";
    public const string GetRequestById = $"{Base}/requests/{{id}}";
    public const string TrackRequest = $"{Base}/requests/track/{{trackingCode}}";
}

public static class SendReceive
{
    private const string Base = $"{ApiBase}/send-receive/orders";
    public const string Create = Base;
    public const string GetMy = $"{Base}/my";
    public const string GetById = $"{Base}/{{id}}";
    public const string Confirm = $"{Base}/{{id}}/confirm";
    public const string Complete = $"{Base}/{{id}}/complete";
}

public static class LockerEvents
{
    private const string Base = $"{ApiBase}/lockers";
    public const string GetLockerEvents = $"{Base}/{{id}}/events";
    public const string GetSlotEvents = $"{Base}/{{id}}/slots/{{slotIndex}}/events";
}

public static class DeviceTokens
{
    private const string Base = $"{ApiBase}/device-tokens";
    public const string GetMy = $"{Base}/my";
    public const string Delete = $"{Base}/{{id}}";
}
```

## 4. Ghi chú quan trọng
- Nếu collection đã tồn tại nhưng chưa có API, backend sẽ không thể dùng được.
- Tên collection nên chuẩn hóa:
  - chỉ giữ `refresh_tokens`, xóa hoặc hợp nhất `refreshTokens`
  - chỉ dùng `locker_slots` nếu cần tách riêng, nếu không thì lưu embedded trong `lockers.slots`

## 5. Tiếp theo bạn cần làm
1. Viết controller + service + repository cho từng feature mới.
2. UI mobile gọi đúng endpoint mới.
3. Kiểm tra lại schema MongoDB để field trùng với model mobile.
4. Tạo index cho các collection mới nếu cần.

POST /api/send-receive/orders
Mục đích: Tạo một đơn hàng gửi/nhận mới.
Hoạt động: Người gửi sẽ gọi API này sau khi đã nhập đủ thông tin về người nhận và chọn ngăn tủ. Backend sẽ xử lý yêu cầu, tạo một bản ghi trong collection send_receive_orders, và chuẩn bị gửi thông báo cho người nhận.
Dữ liệu đầu vào (dự kiến): { "recipientContact": "0987654321", "lockerId": "...", "slotIndex": 5, "notes": "Gửi bạn A cuốn sách" }.
Kết quả: Trả về thông tin xác nhận đơn hàng đã được tạo.
GET /api/send-receive/orders/my
Mục đích: Lấy danh sách các đơn hàng gửi/nhận liên quan đến người dùng hiện tại.
Hoạt động: API này sẽ trả về một danh sách bao gồm cả những đơn hàng mà người dùng đã gửi và những đơn hàng họ được nhận. Điều này giúp người dùng theo dõi trạng thái các giao dịch của mình.
GET /api/send-receive/orders/{id}
Mục đích: Lấy thông tin chi tiết của một đơn hàng gửi/nhận cụ thể.
Hoạt động: Cung cấp đầy đủ thông tin về một giao dịch, ví dụ: người gửi, người nhận, trạng thái (đang chờ gửi, đang chờ nhận, đã hoàn thành), thời gian, địa điểm...
PATCH /api/send-receive/orders/{id}/confirm
Mục đích: Xác nhận một bước nào đó trong quy trình.
Hoạt động: Endpoint này có thể được dùng cho nhiều mục đích, ví dụ như người nhận xác nhận đã nhận được thông báo, hoặc một bước trung gian nào đó trước khi hoàn tất.
PATCH /api/send-receive/orders/{id}/complete
Mục đích: Đánh dấu đơn hàng đã hoàn tất.
Hoạt động: API này sẽ được gọi sau khi người nhận đã lấy đồ thành công khỏi tủ. Backend sẽ cập nhật trạng thái đơn hàng thành Completed và giải phóng ngăn tủ để người khác có thể sử dụng.