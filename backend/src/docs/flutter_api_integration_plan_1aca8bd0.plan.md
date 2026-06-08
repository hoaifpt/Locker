---
name: Flutter API Integration Plan
overview: Tich hop day du tat ca API Backend vao Flutter app - thay the mock data, bo sung field mapping, them cac luong chua co, va huong dan step-by-step.
todos:
  - id: add-endpoints
    content: Cap nhat api_endpoints.dart - them endpoint con thieu
    status: pending
  - id: new-entities
    content: Tao moi entity files (delivery_request, restaurant, menu_item, food_order)
    status: pending
  - id: fix-wallet-entities
    content: Cap nhat wallet entities - fix field names
    status: pending
  - id: fix-sr-entity
    content: Cap nhat send_receive entity - backend model
    status: pending
  - id: new-models
    content: Tao moi model files (delivery, restaurant, menu, food_order)
    status: pending
  - id: fix-wallet-models
    content: Cap nhat wallet model files - fix fromJson
    status: pending
  - id: wallet-repo
    content: Viet lai wallet_repository.dart - real API
    status: pending
  - id: food-repo
    content: Viet lai food_order_repository.dart - real API
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

## 1. Cap Nhat `api_endpoints.dart`

Them cac endpoint con thieu vao [mobile/lib/core/constants/api_endpoints.dart](mobile/lib/core/constants/api_endpoints.dart):

```dart
// Wallet (them)
static String walletTopUp() => '$apiBase/wallet/top-up';
static String walletTransfer() => '$apiBase/wallet/transfer';
static const String walletBalance = '$apiBase/wallet/balance';
static const String walletTransactions = '$apiBase/wallet/transactions';

// Restaurant & Food Order (them)
static const String restaurants = '$apiBase/restaurants';
static String restaurantById(String id) => '$apiBase/restaurants/$id';
static String restaurantMenu(String id) => '$apiBase/restaurants/$id/menu';
static const String foodOrdersCreate = '$apiBase/food-orders';
static const String foodOrdersMy = '$apiBase/food-orders/my';
static String foodOrderById(String id) => '$apiBase/food-orders/$id';

// Delivery (them)
static const String deliveryPackageSizes = '$apiBase/delivery/package-sizes';
static const String deliveryRequestsCreate = '$apiBase/delivery/requests';
static const String deliveryRequestsMy = '$apiBase/delivery/requests/my';
static String deliveryTrack(String code) => '$apiBase/delivery/requests/track/$code';

// Send/Receive (them)
static const String sendReceiveCreate = '$apiBase/send-receive/orders';
static const String sendReceiveMy = '$apiBase/send-receive/orders/my';
static String sendReceiveById(String id) => '$apiBase/send-receive/orders/$id';
static String sendReceiveConfirm(String id) => '$apiBase/send-receive/orders/$id/confirm';
static String sendReceiveComplete(String id) => '$apiBase/send-receive/orders/$id/complete';

// Packages (them)
static const String packagesGetAll = '$apiBase/packages';
static String packageById(String id) => '$apiBase/packages/$id';

// Orders additional (them)
static const String ordersReserve = '$apiBase/orders/reserve';
static const String ordersAvailabilitySlots = '$apiBase/orders/availability/slots';
static String orderSetPin(String id) => '$apiBase/orders/$id/set-pin';
static String orderActivate(String id) => '$apiBase/orders/$id/activate';
static String orderPayment(String id) => '$apiBase/orders/$id/payment';
static String orderById(String id) => '$apiBase/orders/$id';

// Admin (them)
static String adminUsersUpdateRole(String id) => '$apiBase/admin/users/$id/role';
static String adminUsersDeactivate(String id) => '$apiBase/admin/users/$id/deactivate';
static String adminUsersActivate(String id) => '$apiBase/admin/users/$id/activate';

// Device Tokens (them)
static const String deviceTokensMy = '$apiBase/device-tokens';
static String deviceTokenDelete(String id) => '$apiBase/device-tokens/$id';

// Notifications (them)
static String notificationsRegisterDevice() => '$apiBase/notifications/register-device';
```

## 2. Tao Moi/Doi Entity Files

### 2a. Tao `wallet/domain/entities/wallet_overview.dart` (doi tu `int` sang `double`)

```dart
class WalletOverview {
  final double balance;
  final int recentTransactionsCount;  // thay doi tu monthlyChange/points
  final List<WalletTransaction> transactions;
  // xoa: monthlyChange, points
}
```

### 2b. Tao `wallet/domain/entities/wallet_transaction.dart` (do field mapping)

```dart
class WalletTransaction {
  final String id;
  final double amount;
  final String type;        // TopUp, Transfer, Payment, Refund
  final String status;      // Pending, Completed, Failed
  final String? description;
  final DateTime createdAt;
  // xoa: title, subtitle, timeLabel, isIncome (backend khong co)
}
```

### 2c. Tao `delivery/domain/entities/delivery_request.dart` (backend model)

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

### 2d. Tao `food_order/domain/entities/restaurant.dart` (backend model)

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

### 2e. Tao `send_receive/domain/entities/send_receive_order.dart` (backend model)

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

## 3. Cap Nhat Model Files

### 3a. `wallet/data/models/wallet_overview_model.dart` - fix field mapping

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

### 3b. `wallet/data/models/wallet_transaction_model.dart` - fix field mapping

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

### 3c. `food_order/data/models/restaurant_pin_model.dart` - them fromJson

```dart
factory RestaurantPinModel.fromJson(Map<String, dynamic> json) {
  return RestaurantPinModel(
    id: json['id'] as String,
    name: json['name'] as String,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    distanceKm: 0.0,  // backend khong co - gia lap
    offsetX: 0.5,
    offsetY: 0.5,
    isOpen: true,     // backend khong co - gia lap
    tags: [],          // backend khong co
    imageUrl: json['imageUrl'] as String? ?? '',
  );
}
```

### 3d. Tao moi model files: `restaurant_model.dart`, `menu_item_model.dart`, `food_order_model.dart`, `delivery_request_model.dart`, `send_receive_order_model.dart`

## 4. Viet Lai Repository Files (thay mock bang API calls)

### 4a. `wallet/data/wallet_repository.dart` - rewrite

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

### 4b. `food_order/data/food_order_repository.dart` - rewrite

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

### 4c. `delivery/data/delivery_repository.dart` - rewrite

```dart
class DeliveryRepository implements IDeliveryRepository {
  final _client = ApiClient().client;

  @override
  Future<List<DeliveryPackageSize>> getPackageSizes() async {
    final res = await _client.get('/delivery/package-sizes');
    // Backend tra ve string[] ["Small","Medium","Large"]
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

### 4d. `send_receive/data/send_receive_repository.dart` - rewrite

```dart
class SendReceiveRepository implements ISendReceiveRepository {
  final _client = ApiClient().client;

  // Locker sizes lay tu /packages endpoint thay vi mock
  @override
  Future<List<LockerSize>> getAvailableLockerSizes() async {
    final res = await _client.get('/packages');
    return (res.data as List)
        .map((e) => LockerSizeModel.fromJson(e))
        .toList();
  }

  // Storage durations la static data (backend khong co)
  @override
  Future<List<StorageDuration>> getStorageDurations() async { /* keep mock */ }

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
  Future<void> confirmOrder(String orderId) async {
    await _client.patch('/send-receive/orders/$orderId/confirm');
  }

  @override
  Future<void> completeOrder(String orderId) async {
    await _client.patch('/send-receive/orders/$orderId/complete');
  }
}
```

## 5. Bo Sung Them Repository Methods

### 5a. `orders/data/orders_repository.dart` - bo sung methods

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

### 5b. `locker_detail/data/locker_detail_repository.dart` - bo sung

```dart
// Them open locker voi slotIndex
Future<void> openLocker(String lockerId, int slotIndex, {String? reason});
```

### 5c. Tao `packages/data/packages_repository.dart`

```dart
Future<List<Package>> getAllPackages();
Future<Package> getPackageById(String id);
```

## 6. Luong Step-by-Step Chi Tiet

### Luong 1: Dang Nhap / Dang Ky

```
1. POST /auth/register {username, email, fullName?, password}
   -> 200 { message: "..." }
2. POST /auth/login {identifier, password}
   -> 200 { token, refreshToken, username, role, expiresAt }
   -> Flutter: luu token vao SharedPreferences, goi apiClient.setToken()
3. GET /users/me
   -> 200 UserDto -> hien thi profile
```

### Luong 2: Gui Do (Send/Receive)

```
1. GET /packages -> lay danh sach kich thuoc + gia
2. User chon locker -> GET /lockers/available
3. User chon slot -> POST /send-receive/orders
   Body: { lockerId, slotIndex, receiverPhone, pinCode?, notes? }
   -> 201 SendReceiveOrderDto
4. GET /send-receive/orders/my
   -> danh sach don gui
5. PATCH /send-receive/orders/{id}/confirm (nguoi nhan xac nhan)
   -> 200 {}
6. PATCH /send-receive/orders/{id}/complete (hoan tat)
   -> 200 {}
```

### Luong 3: Dat Locker / Order

```
1. GET /packages -> lay danh sach goi
2. GET /lockers/available -> lay danh sach locker trong
3. GET /orders/availability/slots?lockerId=&fromTime=&toTime=
   -> AvailableSlotDto[]
4. POST /orders/reserve
   Body: { lockerId, slotIndex, packageId, mobileNumber, checkInTime, durationHours, notes? }
   -> 201 OrderConfirmationDto { orderId, status, totalAmount, checkInTime, checkOutTime, expirationTime }
5. POST /payments
   Body: { bookingId: orderId, method: "Wallet" | "MoMo" | "VNPay" }
   -> 201 PaymentDto
6. PATCH /orders/{orderId}/confirm
   -> 200 OrderDto
7. PATCH /orders/{orderId}/activate
   -> 200 OrderDto
8. POST /orders/{orderId}/set-pin { pin: "123456" }
   -> 204
9. (Nguoi nhan) POST /orders/{orderId}/verify-pin { pin: "123456" }
   -> { message: "..." }
10. PATCH /orders/{orderId}/complete
    -> 200 OrderDto
```

### Luong 4: Giao Hang (Delivery)

```
1. GET /delivery/package-sizes -> ["Small","Medium","Large"]
2. POST /delivery/requests
   Body: { senderName, receiverPhone, lockerId, slotIndex, packageSize }
   -> 201 DeliveryRequestDto { id, trackingCode, status }
3. GET /delivery/requests/my
   -> danh sach yeu cau
4. GET /delivery/requests/track/{trackingCode}
   -> DeliveryRequestDto (xem trang thai)
```

### Luong 5: Order Do An (Food Order)

```
1. GET /restaurants -> danh sach nha hang
2. GET /restaurants/{id} -> chi tiet nha hang
3. GET /restaurants/{id}/menu -> danh sach mon
4. POST /food-orders
   Body: { restaurantId, lockerId, slotIndex, items: [{menuItemId, name, quantity, unitPrice, notes?}], deliveryNotes? }
   -> 201 FoodOrderDto
5. GET /food-orders/my -> lich su don hang
```

### Luong 6: Vi (Wallet)

```
1. GET /wallet/overview
   -> { balance: decimal, recentTransactionsCount: int }
2. GET /wallet/transactions
   -> [{ id, amount, type, status, description, createdAt }]
3. GET /wallet/balance
   -> { balance: decimal }
4. POST /wallet/top-up
   Body: { amount, referenceId? }
5. POST /wallet/transfer
   Body: { receiverId, amount, note? }
```

### Luong 7: Locker Map va Mo Tủ

```
1. GET /lockers/map
   -> [{ lockerId, slotIndex, size, status, sensorState, hubLocation }]
2. POST /lockers/{lockerId}/open
   Body: { slotIndex: int, reason?: string }
   -> 204
3. GET /lockers/{lockerId}
   -> LockerDto (chi tiet + slots)
```

## 7. File Tree - Tat Ca Thay Doi

```
mobile/lib/
+ core/constants/api_endpoints.dart     [sua - them endpoint]
+ features/wallet/
  + domain/entities/wallet_overview.dart [sua - doi field]
  + domain/entities/wallet_transaction.dart [sua - doi field]
  + domain/entities/delivery_request.dart [tao moi]
  + domain/entities/restaurant.dart [tao moi]
  + domain/entities/menu_item.dart [tao moi]
  + domain/entities/food_order.dart [tao moi]
  + domain/entities/send_receive_order.dart [sua - backend model]
  + domain/repositories/  [sua interface]
  + data/models/wallet_overview_model.dart [sua]
  + data/models/wallet_transaction_model.dart [sua]
  + data/models/delivery_request_model.dart [tao moi]
  + data/models/restaurant_model.dart [tao moi]
  + data/models/menu_item_model.dart [tao moi]
  + data/models/food_order_model.dart [tao moi]
  + data/models/send_receive_order_model.dart [sua]
  + data/wallet_repository.dart [sua - API]
  + data/food_order_repository.dart [sua - API]
  + data/delivery_repository.dart [sua - API]
  + data/send_receive_repository.dart [sua - API]
  + data/packages_repository.dart [tao moi]
+ features/orders/data/orders_repository.dart [bo sung]
+ features/locker_detail/data/locker_detail_repository.dart [bo sung]
```

## 8. Trinh Tu Thuc Hien (Execution Order)

1. **Cap nhat api_endpoints.dart** - them tat ca endpoint con thieu
2. **Tao moi entity files** - delivery_request, restaurant, menu_item, food_order
3. **Cap nhat wallet entities** - fix field names
4. **Cap nhat send_receive entity** - backend model thay mock
5. **Tao moi model files** - delivery_request_model, restaurant_model, menu_item_model, food_order_model
6. **Cap nhat wallet model files** - fix fromJson
7. **Viet lai wallet_repository.dart** - real API
8. **Viet lai food_order_repository.dart** - real API
9. **Viet lai delivery_repository.dart** - real API
10. **Viet lai send_receive_repository.dart** - real API + real locker sizes
11. **Tao packages_repository.dart**
12. **Cap nhat orders_repository.dart** - bo sung methods
13. **Tao/Doi repository interfaces** - i_wallet_repository, i_food_order_repository, i_delivery_repository, i_send_receive_repository
