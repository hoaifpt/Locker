---
name: Flutter API Integration Plan
overview: Tich hop day du cac API Backend vao Flutter app, thay the mock data, bo sung field mapping, cap nhat contract auth register auto-login, va huong dan step-by-step cho frontend.
todos:
  - id: add-endpoints
    content: Cap nhat api_endpoints.dart - them endpoint con thieu
    status: pending
  - id: auth-register-response
    content: Cap nhat sign_up/auth flow - register tra ve AuthResponse va auto-login
    status: pending
  - id: new-entities
    content: Tao moi entity files (delivery_request, restaurant, menu_item, food_order)
    status: pending
  - id: fix-wallet-entities
    content: Cap nhat wallet entities - fix field names
    status: pending
  - id: fix-sr-entity
    content: Cap nhat send_receive entity - backend DTO moi
    status: pending
  - id: new-models
    content: Tao moi model files (delivery, restaurant, menu, food_order, send_receive)
    status: pending
  - id: fix-wallet-models
    content: Cap nhat wallet model files - fix fromJson
    status: pending
  - id: wallet-repo
    content: Viet lai wallet_repository.dart - real API
    status: pending
  - id: food-repo
    content: Viet lai food_order_repository.dart - real API + restaurants/menu
    status: pending
  - id: delivery-repo
    content: Viet lai delivery_repository.dart - real API
    status: pending
  - id: sr-repo
    content: Viet lai send_receive_repository.dart - real API
    status: pending
  - id: packages-repo
    content: Tao packages_repository.dart
    status: pending
  - id: orders-repo
    content: Cap nhat orders_repository.dart - bo sung methods
    status: pending
  - id: repo-interfaces
    content: Tao/Doi repository interfaces
    status: pending
isProject: false
---

# Plan: Day Du Tich Hop Flutter API - Backend Locker

Plan nay da duoc cap nhat de match backend moi nhat, bao gom:
- `POST /auth/register` gio tra ve `AuthResponse` de auto-login ngay.
- Send/Receive da co them `GET /send-receive/orders/{id}`, `PATCH /confirm`, `PATCH /complete`.
- Restaurants da co controller va co the dung ngay voi `GET /restaurants`, `GET /restaurants/{id}`, `GET /restaurants/{id}/menu`.

## 1. Cap Nhat `api_endpoints.dart`

File tham chieu: [mobile/lib/core/constants/api_endpoints.dart](mobile/lib/core/constants/api_endpoints.dart)

### 1a. Endpoint da co san, khong can them lai

Cac endpoint sau da ton tai trong `api_endpoints.dart`, frontend chi can su dung lai:

```dart
static const String notificationsGetMy = '$apiBase/notifications/my';
static String notificationsMarkAsRead(String id) => '$apiBase/notifications/$id/mark-as-read';
static const String notificationsMarkAllAsRead = '$apiBase/notifications/mark-all-as-read';
static const String packagesGetAll = '$apiBase/packages';
static String packagesGetById(String id) => '$apiBase/packages/$id';
static String ordersActivate(String id) => '$apiBase/orders/$id/activate';
static String ordersSetPin(String id) => '$apiBase/orders/$id/set-pin';
static String ordersGetById(String id) => '$apiBase/orders/$id';
```

### 1b. Endpoint can them vao file constants

```dart
// Wallet
static const String walletBalance = '$apiBase/wallet/balance';
static const String walletTransactions = '$apiBase/wallet/transactions';
static const String walletOverview = '$apiBase/wallet/overview';
static const String walletTopUp = '$apiBase/wallet/top-up';
static const String walletTransfer = '$apiBase/wallet/transfer';

// Restaurant & Food Order
static const String restaurants = '$apiBase/restaurants';
static String restaurantById(String id) => '$apiBase/restaurants/$id';
static String restaurantMenu(String id) => '$apiBase/restaurants/$id/menu';
static const String foodOrdersCreate = '$apiBase/food-orders';
static const String foodOrdersMy = '$apiBase/food-orders/my';
static String foodOrderById(String id) => '$apiBase/food-orders/$id';

// Delivery
static const String deliveryPackageSizes = '$apiBase/delivery/package-sizes';
static const String deliveryRequestsCreate = '$apiBase/delivery/requests';
static const String deliveryRequestsMy = '$apiBase/delivery/requests/my';
static String deliveryTrack(String code) => '$apiBase/delivery/requests/track/$code';

// Send/Receive
static const String sendReceiveCreate = '$apiBase/send-receive/orders';
static const String sendReceiveMy = '$apiBase/send-receive/orders/my';
static String sendReceiveById(String id) => '$apiBase/send-receive/orders/$id';
static String sendReceiveConfirm(String id) => '$apiBase/send-receive/orders/$id/confirm';
static String sendReceiveComplete(String id) => '$apiBase/send-receive/orders/$id/complete';

// Orders additional
static const String ordersReserve = '$apiBase/orders/reserve';
static const String ordersAvailabilitySlots = '$apiBase/orders/availability/slots';
static String orderPayment(String id) => '$apiBase/orders/$id/payment';

// Notifications
static String notificationsRegisterDevice() => '$apiBase/notifications/register-device';
```

## 2. Cap Nhat Luong Auth Register Theo Backend Moi

### 2a. Contract moi cua `POST /auth/register`

Backend khong con tra `{ message: '...' }` nua.

Contract moi:

```json
{
  "token": "jwt-access-token",
  "refreshToken": "jwt-refresh-token",
  "username": "user123",
  "role": "User",
  "expiresAt": "2026-06-08T07:00:00Z"
}
```

### 2b. Frontend files can sua

- `mobile/lib/features/sign_up/data/sign_up_repository.dart`
- `mobile/lib/features/sign_up/presentation/controllers/sign_up_cubit.dart`
- `mobile/lib/features/auth/domain/repositories/i_auth_repository.dart`
- `mobile/lib/features/auth/data/auth_repository.dart`

### 2c. Ke hoach cap nhat

1. `sign_up_repository.dart`
   - doi tu hardcode `token: ''` sang parse response that tu backend
   - co the map truc tiep vao `SignUpResponseModel` neu model da chua token/refresh token

2. `auth_repository.dart`
   - bo sung method nhu `autoLoginWithToken(String accessToken, String refreshToken)`
   - method nay luu token vao `SharedPreferences` va goi `ApiClient.setToken()`

3. `sign_up_cubit.dart`
   - sau khi register thanh cong, luu token ngay va emit state dang nhap thanh cong
   - neu can profile chi tiet, goi them `/users/me`

### 2d. Luong frontend moi sau khi sua

```text
1. POST /auth/register { username, email, password, fullName?, phoneNumber? }
2. -> 200 AuthResponse { token, refreshToken, username, role, expiresAt }
3. Flutter luu token vao local storage
4. ApiClient gan Bearer token
5. Co the goi GET /users/me de lay profile day du
6. Dieu huong vao home/profile flow
```

## 3. Tao Moi/Doi Entity Files

### 3a. Tao `wallet/domain/entities/wallet_overview.dart`

```dart
class WalletOverview {
  final double balance;
  final int recentTransactionsCount;
  final List<WalletTransaction> transactions;
}
```

### 3b. Tao `wallet/domain/entities/wallet_transaction.dart`

```dart
class WalletTransaction {
  final String id;
  final double amount;
  final String type;
  final String status;
  final String? description;
  final DateTime createdAt;
}
```

### 3c. Tao `delivery/domain/entities/delivery_request.dart`

```dart
class DeliveryRequest {
  final String id;
  final String senderName;
  final String receiverPhone;
  final String lockerId;
  final int slotIndex;
  final String packageSize;
  final String trackingCode;
  final String status;
  final DateTime createdAt;
}
```

### 3d. Tao `food_order/domain/entities/restaurant.dart`

```dart
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String imageUrl;
  final double rating;
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
}

class FoodOrder {
  final String id;
  final String restaurantId;
  final String lockerId;
  final int slotIndex;
  final List<FoodOrderItem> items;
  final double totalAmount;
  final String status;
  final String? deliveryNotes;
  final DateTime createdAt;
}

class FoodOrderItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String? notes;
}
```

### 3e. Tao/Sua `send_receive/domain/entities/send_receive_order.dart`

Backend DTO moi khong con theo shape mock cu.

```dart
class SendReceiveOrder {
  final String id;
  final String senderId;
  final String receiverPhone;
  final String lockerId;
  final int slotIndex;
  final String status;
  final String? notes;
  final DateTime createdAt;
}
```

Luu y:
- xoa phu thuoc vao `lockerCode`, `location`, `size`, `duration`, `estimatedFee` neu entity cu dang dung cac field do
- neu UI van can text hien thi, bo sung adapter/view-model rieng o presentation layer

## 4. Cap Nhat Model Files

### 4a. `wallet/data/models/wallet_overview_model.dart`

```dart
factory WalletOverviewModel.fromJson(Map<String, dynamic> json) {
  return WalletOverviewModel(
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    recentTransactionsCount: json['recentTransactionsCount'] as int? ?? 0,
    transactions: (json['transactions'] as List<dynamic>?)
            ?.map((e) => WalletTransactionModel.fromJson(e))
            .toList() ?? [],
  );
}
```

### 4b. `wallet/data/models/wallet_transaction_model.dart`

```dart
factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
  return WalletTransactionModel(
    id: json['id'] as String? ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    type: json['type']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    description: json['description'] as String?,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}
```

### 4c. `food_order/data/models/restaurant_pin_model.dart`

Them `fromJson` de map tu backend restaurant response vao UI pin model:

```dart
factory RestaurantPinModel.fromJson(Map<String, dynamic> json) {
  return RestaurantPinModel(
    id: json['id'] as String,
    name: json['name'] as String,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    distanceKm: 0.0,
    offsetX: 0.5,
    offsetY: 0.5,
    isOpen: true,
    tags: [],
    imageUrl: json['imageUrl'] as String? ?? '',
  );
}
```

### 4d. Tao moi model files

- `restaurant_model.dart`
- `menu_item_model.dart`
- `food_order_model.dart`
- `delivery_request_model.dart`
- `send_receive_order_model.dart`

### 4e. `send_receive_order_model.dart` can map theo DTO backend moi

```dart
factory SendReceiveOrderModel.fromJson(Map<String, dynamic> json) {
  return SendReceiveOrderModel(
    id: json['id'] as String? ?? '',
    senderId: json['senderId'] as String? ?? '',
    receiverPhone: json['receiverPhone'] as String? ?? '',
    lockerId: json['lockerId'] as String? ?? '',
    slotIndex: json['slotIndex'] as int? ?? 0,
    status: json['status']?.toString() ?? '',
    notes: json['notes'] as String?,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}
```

## 5. Viet Lai Repository Files

### 5a. `wallet/data/wallet_repository.dart`

```dart
class WalletRepository implements IWalletRepository {
  final _client = ApiClient().client;

  @override
  Future<WalletOverview> getWalletOverview() async {
    final res = await _client.get('/wallet/overview');
    return WalletOverviewModel.fromJson(res.data);
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    final res = await _client.get('/wallet/transactions');
    return (res.data as List)
        .map((e) => WalletTransactionModel.fromJson(e))
        .toList();
  }

  @override
  Future<double> getBalance() async {
    final res = await _client.get('/wallet/balance');
    return (res.data['balance'] as num).toDouble();
  }

  @override
  Future<void> topUp(double amount, String? referenceId) async {
    await _client.post('/wallet/top-up', data: {
      'amount': amount,
      if (referenceId != null) 'referenceId': referenceId,
    });
  }

  @override
  Future<void> transfer(String receiverId, double amount, String? note) async {
    await _client.post('/wallet/transfer', data: {
      'receiverId': receiverId,
      'amount': amount,
      if (note != null) 'note': note,
    });
  }
}
```

### 5b. `food_order/data/food_order_repository.dart`

Restaurants backend da san sang, uu tien rewrite phan nay o frontend.

```dart
class FoodOrderRepository implements IFoodOrderRepository {
  final _client = ApiClient().client;

  @override
  Future<List<Restaurant>> getNearbyRestaurants() async {
    final res = await _client.get('/restaurants');
    return (res.data as List)
        .map((e) => RestaurantModel.fromJson(e))
        .toList();
  }

  Future<Restaurant> getRestaurantById(String id) async {
    final res = await _client.get('/restaurants/$id');
    return RestaurantModel.fromJson(res.data);
  }

  @override
  Future<List<MenuItem>> getMenu(String restaurantId) async {
    final res = await _client.get('/restaurants/$restaurantId/menu');
    return (res.data as List)
        .map((e) => MenuItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<FoodOrder> createFoodOrder(CreateFoodOrderRequest req) async {
    final res = await _client.post('/food-orders', data: req.toJson());
    return FoodOrderModel.fromJson(res.data);
  }

  @override
  Future<List<FoodOrder>> getMyOrders() async {
    final res = await _client.get('/food-orders/my');
    return (res.data as List)
        .map((e) => FoodOrderModel.fromJson(e))
        .toList();
  }

  @override
  Future<FoodOrder> getOrderById(String id) async {
    final res = await _client.get('/food-orders/$id');
    return FoodOrderModel.fromJson(res.data);
  }
}
```

### 5c. `delivery/data/delivery_repository.dart`

```dart
class DeliveryRepository implements IDeliveryRepository {
  final _client = ApiClient().client;

  @override
  Future<List<DeliveryPackageSize>> getPackageSizes() async {
    final res = await _client.get('/delivery/package-sizes');
    final sizes = (res.data as List).cast<String>();
    return sizes.map((s) => DeliveryPackageSizeModel(
      id: s.toLowerCase(),
      size: s,
      price: _getPriceForSize(s),
      description: _getDescForSize(s),
      recommended: s == 'Medium',
    )).toList();
  }

  @override
  Future<DeliveryRequest> createSendRequest(SendDeliveryRequest req) async {
    final res = await _client.post('/delivery/requests', data: {
      'senderName': 'currentUserName',
      'receiverPhone': req.receiverPhone,
      'lockerId': req.lockerId,
      'slotIndex': req.slotIndex,
      'packageSize': req.packageSize,
    });
    return DeliveryRequestModel.fromJson(res.data);
  }

  @override
  Future<List<DeliveryRequest>> getMyRequests() async {
    final res = await _client.get('/delivery/requests/my');
    return (res.data as List)
        .map((e) => DeliveryRequestModel.fromJson(e))
        .toList();
  }

  @override
  Future<DeliveryRequest> trackDelivery(String trackingCode) async {
    final res = await _client.get('/delivery/requests/track/$trackingCode');
    return DeliveryRequestModel.fromJson(res.data);
  }
}
```

### 5d. `send_receive/data/send_receive_repository.dart`

Repository hien tai dang mock. Can rewrite theo contract backend moi.

```dart
class SendReceiveRepository implements ISendReceiveRepository {
  final _client = ApiClient().client;

  @override
  Future<List<LockerSize>> getAvailableLockerSizes() async {
    final res = await _client.get('/packages');
    return (res.data as List)
        .map((e) => LockerSizeModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<StorageDuration>> getStorageDurations() async {
    // Backend chua co endpoint cho storage durations
    // Tam giu static data o client
  }

  @override
  Future<SendReceiveOrder> createSendReceiveOrder({
    required String lockerId,
    required int slotIndex,
    required String receiverPhone,
    String? pinCode,
    String? notes,
  }) async {
    final res = await _client.post('/send-receive/orders', data: {
      'lockerId': lockerId,
      'slotIndex': slotIndex,
      'receiverPhone': receiverPhone,
      if (pinCode != null) 'pinCode': pinCode,
      if (notes != null) 'notes': notes,
    });
    return SendReceiveOrderModel.fromJson(res.data);
  }

  @override
  Future<List<SendReceiveOrder>> getMyOrders() async {
    final res = await _client.get('/send-receive/orders/my');
    return (res.data as List)
        .map((e) => SendReceiveOrderModel.fromJson(e))
        .toList();
  }

  @override
  Future<SendReceiveOrder> getOrderById(String id) async {
    final res = await _client.get('/send-receive/orders/$id');
    return SendReceiveOrderModel.fromJson(res.data);
  }

  @override
  Future<void> confirmOrder(String orderId) async {
    await _client.patch('/send-receive/orders/$orderId/confirm');
  }

  @override
  Future<void> completeOrder(String orderId) async {
    await _client.patch('/send-receive/orders/$orderId/complete');
  }
}
```

### 5e. Ghi chu quan trong cho SendReceive UI

Flutter implementation hien tai dang co contract cu nhu `sizeId`, `durationId`, `lockerCode`, `estimatedFee`.

Can doi frontend flow sang contract backend that su:

```text
POST /send-receive/orders
Body: {
  lockerId,
  slotIndex,
  receiverPhone,
  pinCode?,
  notes?
}
```

Neu UI van can `size` va `duration`, can tach:
- `size` lay tu `/packages`
- `duration` tam thoi la static local data
- khong map 2 field nay vao `SendReceiveOrderDto`

## 6. Bo Sung Them Repository Methods

### 6a. `orders/data/orders_repository.dart`

```dart
Future<OrderDetail> reserveSlot(ReserveSlotRequest req) async;
Future<void> confirmOrder(String id) async;
Future<void> activateOrder(String id, {String? accountNumber}) async;
Future<void> completeOrder(String id, {String? notes}) async;
Future<void> cancelOrder(String id, {String? reason}) async;
Future<void> extendOrder(String id, int additionalHours) async;
Future<void> setOrderPin(String id, String pin) async;
Future<Payment> createPayment(String orderId, String method) async;
```

### 6b. `locker_detail/data/locker_detail_repository.dart`

```dart
Future<void> openLocker(String lockerId, int slotIndex, {String? reason});
```

### 6c. Tao `packages/data/packages_repository.dart`

```dart
Future<List<Package>> getAllPackages();
Future<Package> getPackageById(String id);
```

### 6d. Repository interfaces can doi

- `i_auth_repository.dart`: them auto-login helper method
- `i_food_order_repository.dart`: them `getRestaurantById()` neu chua co
- `i_send_receive_repository.dart`: them `getOrderById()`, `completeOrder()` neu chua co
- `i_delivery_repository.dart`: ra soat lai ten method va request shape

## 7. Luong Step-by-Step Chi Tiet

### Luong 1: Dang Nhap / Dang Ky

```text
1. POST /auth/register { username, email, fullName?, password, phoneNumber? }
   -> 200 { token, refreshToken, username, role, expiresAt }
2. Flutter luu token vao SharedPreferences, goi apiClient.setToken()
3. GET /users/me
   -> 200 UserDto -> hien thi profile
```

### Luong 2: Gui Do (Send/Receive)

```text
1. GET /packages -> lay danh sach kich thuoc + gia
2. User chon locker -> GET /lockers/available
3. User chon slot -> POST /send-receive/orders
   Body: { lockerId, slotIndex, receiverPhone, pinCode?, notes? }
   -> 200/201 SendReceiveOrderDto
4. GET /send-receive/orders/my
   -> danh sach don gui
5. GET /send-receive/orders/{id}
   -> chi tiet don gui
6. PATCH /send-receive/orders/{id}/confirm
   -> 200 OK
7. PATCH /send-receive/orders/{id}/complete
   -> 200 OK
```

### Luong 3: Dat Locker / Order

```text
1. GET /packages -> lay danh sach goi
2. GET /lockers/available -> lay danh sach locker trong
3. GET /orders/availability/slots?lockerId=&fromTime=&toTime=
   -> AvailableSlotDto[]
4. POST /orders/reserve
   Body: { lockerId, slotIndex, packageId, mobileNumber, checkInTime, durationHours, notes? }
   -> 201 OrderConfirmationDto { orderId, status, totalAmount, checkInTime, checkOutTime, expirationTime }
5. POST /payments
   Body: { bookingId: orderId, method: 'Wallet' | 'MoMo' | 'VNPay' }
   -> 201 PaymentDto
6. PATCH /orders/{orderId}/confirm
   -> 200 OrderDto
7. PATCH /orders/{orderId}/activate
   -> 200 OrderDto
8. POST /orders/{orderId}/set-pin { pin: '123456' }
   -> 204
9. POST /orders/{orderId}/verify-pin { pin: '123456' }
   -> { message: '...' }
10. PATCH /orders/{orderId}/complete
    -> 200 OrderDto
```

### Luong 4: Giao Hang (Delivery)

```text
1. GET /delivery/package-sizes -> ['Small', 'Medium', 'Large']
2. POST /delivery/requests
   Body: { senderName, receiverPhone, lockerId, slotIndex, packageSize }
   -> 201 DeliveryRequestDto { id, trackingCode, status }
3. GET /delivery/requests/my
   -> danh sach yeu cau
4. GET /delivery/requests/track/{trackingCode}
   -> DeliveryRequestDto
```

### Luong 5: Order Do An (Food Order)

```text
1. GET /restaurants -> danh sach nha hang
2. GET /restaurants/{id} -> chi tiet nha hang
3. GET /restaurants/{id}/menu -> danh sach mon
4. POST /food-orders
   Body: { restaurantId, lockerId, slotIndex, items: [{ menuItemId, name, quantity, unitPrice, notes? }], deliveryNotes? }
   -> 201 FoodOrderDto
5. GET /food-orders/my -> lich su don hang
6. GET /food-orders/{id} -> chi tiet don hang
```

### Luong 6: Vi (Wallet)

```text
1. GET /wallet/overview
   -> { balance: decimal, recentTransactionsCount: int, transactions?: [] }
2. GET /wallet/transactions
   -> [{ id, amount, type, status, description, createdAt }]
3. GET /wallet/balance
   -> { balance: decimal }
4. POST /wallet/top-up
   Body: { amount, referenceId? }
5. POST /wallet/transfer
   Body: { receiverId, amount, note? }
```

### Luong 7: Locker Map va Mo Tu

```text
1. GET /lockers/map
   -> [{ lockerId, slotIndex, size, status, sensorState, hubLocation }]
2. POST /lockers/{lockerId}/open
   Body: { slotIndex: int, reason?: string }
   -> 204
3. GET /lockers/{lockerId}
   -> LockerDto (chi tiet + slots)
```

## 8. File Tree - Tat Ca Thay Doi

```text
mobile/lib/
+ core/constants/api_endpoints.dart                           [sua - them endpoint con thieu]
+ features/auth/domain/repositories/i_auth_repository.dart    [sua - auto login helper]
+ features/auth/data/auth_repository.dart                     [sua - luu token tu register response]
+ features/sign_up/data/sign_up_repository.dart               [sua - parse AuthResponse]
+ features/sign_up/presentation/controllers/sign_up_cubit.dart [sua - auto-login flow]
+ features/wallet/
  + domain/entities/wallet_overview.dart                      [sua - doi field]
  + domain/entities/wallet_transaction.dart                   [sua - doi field]
+ features/delivery/
  + domain/entities/delivery_request.dart                     [tao moi]
  + data/models/delivery_request_model.dart                   [tao moi]
  + data/delivery_repository.dart                             [sua - API]
+ features/food_order/
  + domain/entities/restaurant.dart                           [tao moi]
  + domain/entities/menu_item.dart                            [tao moi neu tach file]
  + domain/entities/food_order.dart                           [tao moi]
  + data/models/restaurant_model.dart                         [tao moi]
  + data/models/menu_item_model.dart                          [tao moi]
  + data/models/food_order_model.dart                         [tao moi]
  + data/models/restaurant_pin_model.dart                     [sua - them fromJson]
  + data/food_order_repository.dart                           [sua - API]
+ features/menu/
  + data/menu_repository.dart                                 [sua - GET /restaurants/{id}/menu neu can tach]
+ features/send_receive/
  + domain/entities/send_receive_order.dart                   [sua - backend DTO moi]
  + domain/repositories/i_send_receive_repository.dart        [sua interface]
  + data/models/send_receive_order_model.dart                 [sua - fromJson backend]
  + data/send_receive_repository.dart                         [sua - API]
+ features/packages/
  + data/packages_repository.dart                             [tao moi]
+ features/orders/data/orders_repository.dart                 [bo sung]
+ features/locker_detail/data/locker_detail_repository.dart   [bo sung]
```

## 9. Trinh Tu Thuc Hien (Execution Order)

1. Cap nhat `api_endpoints.dart`
2. Cap nhat auth register response + auto-login flow
3. Cap nhat send_receive entity/model/interface/repository theo DTO va endpoint moi
4. Cap nhat restaurants + menu + food_order repositories/models
5. Cap nhat delivery repositories/models
6. Cap nhat wallet entities/models/repository
7. Tao `packages_repository.dart`
8. Cap nhat `orders_repository.dart` va `locker_detail_repository.dart`
9. Ra soat presentation layer/cubit de bo sung flow `completeOrder`, `getOrderById`, va redirect sau register

## 10. Ghi Chu Uu Tien Cho Frontend Team

Uu tien cao nhat de frontend co the dung ngay voi backend moi:
1. Auth register auto-login
2. Send/Receive real API
3. Restaurants + Menu + Food Order

Cac phan delivery, wallet, orders roadmap co the tiep tuc sau neu can chia sprint.
