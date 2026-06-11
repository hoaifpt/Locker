---
name: Flutter API Integration Plan - Updated
overview: Tich hop day du cac API Backend vao Flutter app. Phien ban nay da duoc cap nhat chinh xac theo backend source code thuc te ngay 2026-06-11.
todos:
  - id: add-endpoints
    content: Cap nhat api_endpoints.dart - them tat ca endpoints moi
    status: pending
  - id: auth-flow
    content: Cap nhat auth flow - register tra ve AuthResponse, auto-login
    status: pending
  - id: new-entities
    content: Tao moi entity files (restaurant, menu_item, food_order)
    status: pending
  - id: fix-entities
    content: Cap nhat entities - senderName, pinCode, lockerId, slotIndex
    status: pending
  - id: models
    content: Tao/Doi model files - tuong ung voi backend DTOs
    status: pending
  - id: repositories
    content: Viet lai repositories - su dung real API
    status: pending
  - id: flows
    content: Cap nhat UI flows theo backend contracts
    status: pending
isProject: false
---

# Plan: Flutter API Integration - Backend Locker (Updated 2026-06-11)

Plan nay da duoc cap nhat chinh xac theo backend source code thuc te.

---

## 0. Backend API Contracts - Chinh Xac Tu Source Code

### 0a. Auth Endpoints

**POST /api/auth/register**
```json
// Request
{ "username", "email", "password", "fullName?", "phoneNumber?" }
// Response 200
{ "token", "refreshToken", "username", "role", "expiresAt" }
// Response 409 - Conflict
{ "message": "Email da duoc su dung." }
```

**POST /api/auth/login**
```json
// Request
{ "identifier": "email hoac phone", "password" }
// Response 200
{ "token", "refreshToken", "username", "role", "expiresAt" }
```

### 0b. User Endpoints

**GET /api/users/me**
```json
// Response 200
{ "id", "userName", "email", "fullName", "phoneNumber", "role", "emailConfirmed" }
```

**PUT /api/users/me**
```json
// Request
{ "email", "fullName" }
// Response 200 - UserDto
```

**POST /api/users/me/change-password**
```json
// Request
{ "currentPassword", "newPassword" }
// Response 204 - NoContent
```

### 0c. Locker Endpoints

**GET /api/lockers** - [Authorize]
**GET /api/lockers/available** - [AllowAnonymous]
**GET /api/lockers/map** - [AllowAnonymous]
**GET /api/lockers/{id}** - [Authorize]
**POST /api/lockers/{id}/open** - [Authorize]
```json
// Request
{ "slotIndex": int, "reason?": string }
```

### 0d. Order Endpoints

**POST /api/orders/reserve** - [Authorize]
```json
// Request
{ "lockerId", "slotIndex", "packageId", "checkInTime", "durationHours", "mobileNumber", "notes?" }
// Response 201
{
  "orderId": "guid",
  "status": "Initiated",
  "totalAmount": decimal,
  "checkInTime": "datetime",
  "checkOutTime": "datetime",
  "expirationTime": "datetime",
  "message": "string"
}
```

**POST /api/payments** - [Authorize]
```json
// Request
{ "bookingId": "guid", "method": "string" }
// Response 201 - PaymentDto
{ "id", "bookingId", "userId", "amount", "method", "status", "createdAt" }
```

**PATCH /api/orders/{id}/confirm** - [Authorize]
```json
// Request
{ "notes?": string }
// Response 200 - OrderDto
// Require: Payment must be Completed
```

**PATCH /api/orders/{id}/activate** - [Authorize]
```json
// NO body required
// Response 200 - OrderDto
// Require: Status = Reserved or Paid, within check-in window
```

**PATCH /api/orders/{id}/complete** - [Authorize]
```json
// Request
{ "notes?": string }
// Response 200 - OrderDto
```

**PATCH /api/orders/{id}/cancel** - [Authorize]
```json
// Request
{ "cancellationReason?": string }
// Response 200 - OrderDto
```

**POST /api/orders/{id}/extend** - [Authorize]
```json
// Request
{ "additionalHours": int }
// Response 200 - OrderDto
```

### 0e. Food Order Endpoints

**GET /api/restaurants** - [Authorize]
```json
// Response 200 - RestaurantDto[]
{ "id", "name", "description", "address", "imageUrl", "rating" }
```

**GET /api/restaurants/{id}** - [Authorize]
**GET /api/restaurants/{id}/menu** - [Authorize]

**POST /api/food-orders** - [Authorize]
```json
// Request
{
  "restaurantId": "guid",
  "lockerId": "guid",        // REQUIRED
  "slotIndex": int,          // REQUIRED
  "items": [
    { "menuItemId": "guid", "quantity": int, "notes?": string }
  ],
  "deliveryNotes?": string
}
// Response 200 - FoodOrderDto
// Backend tu dong tao Payment pending
```

**GET /api/food-orders/my** - [Authorize]
**GET /api/food-orders/{id}** - [Authorize]

### 0f. Delivery Endpoints

**GET /api/delivery/package-sizes**
```json
// Response 200
["Small", "Medium", "Large"]
```

**POST /api/delivery/requests** - [Authorize]
```json
// Request
{
  "senderName": string,      // REQUIRED - lay tu current user
  "receiverPhone": string,
  "lockerId": "guid",
  "slotIndex": int,
  "packageSize": "Small|Medium|Large"
}
// Response 200 - DeliveryRequestDto
{ "id", "userId", "senderName", "receiverPhone", "lockerId", "slotIndex", "packageSize", "trackingCode", "status", "createdAt" }
```

**GET /api/delivery/requests/my** - [Authorize]
**GET /api/delivery/requests/track/{trackingCode}** - [AllowAnonymous]

### 0g. Send/Receive Endpoints

**POST /api/send-receive/orders** - [Authorize]
```json
// Request
{
  "receiverPhone": string,
  "lockerId": "guid",
  "slotIndex": int,
  "pinCode": string,         // REQUIRED
  "notes?": string
}
// Response 200 - SendReceiveOrderDto
{ "id", "senderId", "receiverPhone", "lockerId", "slotIndex", "status", "notes", "createdAt" }
```

**GET /api/send-receive/orders/my** - [Authorize]
**GET /api/send-receive/orders/{id}** - [Authorize]

**PATCH /api/send-receive/orders/{id}/confirm** - [Authorize]
```json
// NO body required
// Response 200
```

**PATCH /api/send-receive/orders/{id}/complete** - [Authorize]
```json
// NO body required
// Response 200
```

### 0h. Wallet Endpoints

**GET /api/wallet/overview** - [Authorize]
```json
// Response 200
{ "balance": decimal, "recentTransactionsCount": int }
// KHONG co transactions - goi rieng endpoint transactions
```

**GET /api/wallet/transactions** - [Authorize]
```json
// Response 200 - WalletTransactionDto[]
{ "id", "amount", "type", "status", "description", "createdAt" }
```

**GET /api/wallet/balance** - [Authorize]
```json
// Response 200
{ "balance": decimal }
```

**POST /api/wallet/top-up** - [Authorize]
```json
// Request
{ "amount": decimal, "referenceId?": string }
// Response 200
{ "message": "Top up successful" }
```

**POST /api/wallet/top-up/vnpay/init** - [Authorize]
```json
// Request
{ "amount": decimal }
// Response 200 - VnPayInitResponse
```

**GET /api/wallet/top-up/vnpay/return** - [AllowAnonymous]

**POST /api/wallet/transfer** - [Authorize]
```json
// Request
{ "receiverId": "guid", "amount": decimal, "note?": string }
// Response 200
{ "message": "Transfer successful" }
```

---

## 1. Cap Nhat `api_endpoints.dart`

```dart
class ApiEndpoints {
  static const String apiBase = 'http://localhost:5000/api';

  // Auth
  static const String authLogin = '$apiBase/auth/login';
  static const String authRegister = '$apiBase/auth/register';
  static const String authRefresh = '$apiBase/auth/refresh';
  static const String authLogout = '$apiBase/auth/logout';
  static const String authForgotPassword = '$apiBase/auth/forgot-password';
  static const String authResetPassword = '$apiBase/auth/reset-password';

  // User
  static const String userMe = '$apiBase/users/me';
  static const String userChangePassword = '$apiBase/users/me/change-password';

  // Lockers
  static const String lockers = '$apiBase/lockers';
  static const String lockersAvailable = '$apiBase/lockers/available';
  static const String lockersMap = '$apiBase/lockers/map';
  static String lockerById(String id) => '$apiBase/lockers/$id';
  static String lockerOpen(String id) => '$apiBase/lockers/$id/open';

  // Orders
  static const String ordersReserve = '$apiBase/orders/reserve';
  static const String ordersMy = '$apiBase/orders/my';
  static const String ordersAvailabilitySlots = '$apiBase/orders/availability/slots';
  static String orderById(String id) => '$apiBase/orders/$id';
  static String orderConfirm(String id) => '$apiBase/orders/$id/confirm';
  static String orderActivate(String id) => '$apiBase/orders/$id/activate';
  static String orderComplete(String id) => '$apiBase/orders/$id/complete';
  static String orderCancel(String id) => '$apiBase/orders/$id/cancel';
  static String orderExtend(String id) => '$apiBase/orders/$id/extend';

  // Payments
  static const String payments = '$apiBase/payments';
  static String paymentById(String id) => '$apiBase/payments/$id';
  static String paymentByBookingId(String bookingId) => '$apiBase/payments/booking/$bookingId';

  // Restaurants
  static const String restaurants = '$apiBase/restaurants';
  static String restaurantById(String id) => '$apiBase/restaurants/$id';
  static String restaurantMenu(String id) => '$apiBase/restaurants/$id/menu';

  // Food Orders
  static const String foodOrders = '$apiBase/food-orders';
  static const String foodOrdersMy = '$apiBase/food-orders/my';
  static String foodOrderById(String id) => '$apiBase/food-orders/$id';

  // Delivery
  static const String deliveryPackageSizes = '$apiBase/delivery/package-sizes';
  static const String deliveryRequests = '$apiBase/delivery/requests';
  static const String deliveryRequestsMy = '$apiBase/delivery/requests/my';
  static String deliveryTrack(String trackingCode) => '$apiBase/delivery/requests/track/$trackingCode';

  // Send/Receive
  static const String sendReceiveOrders = '$apiBase/send-receive/orders';
  static const String sendReceiveOrdersMy = '$apiBase/send-receive/orders/my';
  static String sendReceiveOrderById(String id) => '$apiBase/send-receive/orders/$id';
  static String sendReceiveOrderConfirm(String id) => '$apiBase/send-receive/orders/$id/confirm';
  static String sendReceiveOrderComplete(String id) => '$apiBase/send-receive/orders/$id/complete';

  // Wallet
  static const String walletOverview = '$apiBase/wallet/overview';
  static const String walletTransactions = '$apiBase/wallet/transactions';
  static const String walletBalance = '$apiBase/wallet/balance';
  static const String walletTopUp = '$apiBase/wallet/top-up';
  static const String walletTransfer = '$apiBase/wallet/transfer';
  static const String walletTopUpVnPayInit = '$apiBase/wallet/top-up/vnpay/init';
  static String walletTopUpVnPayReturn() => '$apiBase/wallet/top-up/vnpay/return';

  // Packages
  static const String packages = '$apiBase/packages';
  static String packageById(String id) => '$apiBase/packages/$id';
}
```

---

## 2. Auth Flow - Register & Auto-Login

### 2a. Contract Response

```dart
class AuthResponseModel {
  final String token;
  final String refreshToken;
  final String username;
  final String role;
  final DateTime expiresAt;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
```

### 2b. Files can sua

1. `sign_up_repository.dart`
   - Goi `POST /api/auth/register`
   - Parse `AuthResponse` tu response
   - Tra ve `AuthResponseModel`

2. `sign_up_cubit.dart`
   - Sau khi register thanh cong, goi `authRepository.loginWithToken(response.token, response.refreshToken)`
   - Chuyen huong sang home screen

3. `auth_repository.dart`
   - Method `loginWithToken(String token, String refreshToken)` - luu token va goi `ApiClient.setToken()`

---

## 3. Entity Files

### 3a. Restaurant Entity

```dart
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String imageUrl;
  final double rating;
}
```

### 3b. MenuItem Entity

```dart
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;        // decimal -> double
  final String imageUrl;
  final String category;
  final bool isAvailable;
}
```

### 3c. FoodOrder Entity

```dart
class FoodOrder {
  final String id;
  final String restaurantId;
  final String lockerId;     // REQUIRED
  final int slotIndex;       // REQUIRED
  final List<FoodOrderItem> items;
  final double totalAmount;
  final String status;        // FoodOrderStatus enum -> String
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

### 3d. DeliveryRequest Entity

```dart
class DeliveryRequest {
  final String id;
  final String senderName;    // REQUIRED - lay tu current user
  final String receiverPhone;
  final String lockerId;
  final int slotIndex;
  final String packageSize;
  final String trackingCode;
  final String status;        // DeliveryStatus enum -> String
  final DateTime createdAt;
}
```

### 3e. SendReceiveOrder Entity

```dart
class SendReceiveOrder {
  final String id;
  final String senderId;
  final String receiverPhone;
  final String lockerId;
  final int slotIndex;
  final String status;        // SendReceiveStatus enum -> String
  final String? notes;
  final DateTime createdAt;
  // pinCode KHONG tra ve tu backend
}
```

### 3f. Wallet Entities

```dart
class WalletOverview {
  final double balance;
  final int recentTransactionsCount;
  // KHONG co transactions - goi rieng GET /wallet/transactions
}

class WalletTransaction {
  final String id;
  final double amount;        // decimal -> double
  final String type;          // TransactionType enum -> String
  final String status;        // TransactionStatus enum -> String
  final String? description;
  final DateTime createdAt;
}
```

---

## 4. Model Files

### 4a. RestaurantModel

```dart
factory RestaurantModel.fromJson(Map<String, dynamic> json) {
  return RestaurantModel(
    id: json['id'].toString(),
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    address: json['address'] as String? ?? '',
    imageUrl: json['imageUrl'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  );
}
```

### 4b. MenuItemModel

```dart
factory MenuItemModel.fromJson(Map<String, dynamic> json) {
  return MenuItemModel(
    id: json['id'].toString(),
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['imageUrl'] as String? ?? '',
    category: json['category'] as String? ?? '',
    isAvailable: json['isAvailable'] as bool? ?? true,
  );
}
```

### 4c. FoodOrderModel

```dart
factory FoodOrderModel.fromJson(Map<String, dynamic> json) {
  return FoodOrderModel(
    id: json['id'].toString(),
    restaurantId: json['restaurantId'].toString(),
    lockerId: json['lockerId'].toString(),
    slotIndex: json['slotIndex'] as int? ?? 0,
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    status: json['status']?.toString() ?? '',
    deliveryNotes: json['deliveryNotes'] as String?,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    items: (json['items'] as List?)
        ?.map((e) => FoodOrderItemModel.fromJson(e))
        .toList() ?? [],
  );
}

factory FoodOrderItemModel.fromJson(Map<String, dynamic> json) {
  return FoodOrderItemModel(
    menuItemId: json['menuItemId'].toString(),
    name: json['name'] as String,
    quantity: json['quantity'] as int? ?? 1,
    unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    notes: json['notes'] as String?,
  );
}
```

### 4d. DeliveryRequestModel

```dart
factory DeliveryRequestModel.fromJson(Map<String, dynamic> json) {
  return DeliveryRequestModel(
    id: json['id'].toString(),
    senderName: json['senderName'] as String,
    receiverPhone: json['receiverPhone'] as String,
    lockerId: json['lockerId'].toString(),
    slotIndex: json['slotIndex'] as int? ?? 0,
    packageSize: json['packageSize'] as String,
    trackingCode: json['trackingCode'] as String,
    status: json['status']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}
```

### 4e. SendReceiveOrderModel

```dart
factory SendReceiveOrderModel.fromJson(Map<String, dynamic> json) {
  return SendReceiveOrderModel(
    id: json['id'].toString(),
    senderId: json['senderId'].toString(),
    receiverPhone: json['receiverPhone'] as String,
    lockerId: json['lockerId'].toString(),
    slotIndex: json['slotIndex'] as int? ?? 0,
    status: json['status']?.toString() ?? '',
    notes: json['notes'] as String?,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}
```

---

## 5. Repository Implementations

### 5a. FoodOrderRepository

```dart
class FoodOrderRepository implements IFoodOrderRepository {
  final _client = ApiClient().client;

  @override
  Future<List<Restaurant>> getRestaurants() async {
    final res = await _client.get(ApiEndpoints.restaurants);
    return (res.data as List)
        .map((e) => RestaurantModel.fromJson(e))
        .toList();
  }

  @override
  Future<Restaurant> getRestaurantById(String id) async {
    final res = await _client.get(ApiEndpoints.restaurantById(id));
    return RestaurantModel.fromJson(res.data);
  }

  @override
  Future<List<MenuItem>> getMenu(String restaurantId) async {
    final res = await _client.get(ApiEndpoints.restaurantMenu(restaurantId));
    return (res.data as List)
        .map((e) => MenuItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<FoodOrder> createFoodOrder({
    required String restaurantId,
    required String lockerId,
    required int slotIndex,
    required List<Map<String, dynamic>> items,
    String? deliveryNotes,
  }) async {
    final res = await _client.post(ApiEndpoints.foodOrders, data: {
      'restaurantId': restaurantId,
      'lockerId': lockerId,
      'slotIndex': slotIndex,
      'items': items,
      if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
    });
    return FoodOrderModel.fromJson(res.data);
  }

  @override
  Future<List<FoodOrder>> getMyOrders() async {
    final res = await _client.get(ApiEndpoints.foodOrdersMy);
    return (res.data as List)
        .map((e) => FoodOrderModel.fromJson(e))
        .toList();
  }

  @override
  Future<FoodOrder> getOrderById(String id) async {
    final res = await _client.get(ApiEndpoints.foodOrderById(id));
    return FoodOrderModel.fromJson(res.data);
  }
}
```

### 5b. DeliveryRepository

```dart
class DeliveryRepository implements IDeliveryRepository {
  final _client = ApiClient().client;

  @override
  Future<List<String>> getPackageSizes() async {
    final res = await _client.get(ApiEndpoints.deliveryPackageSizes);
    return (res.data as List).cast<String>();
  }

  @override
  Future<DeliveryRequest> createDeliveryRequest({
    required String senderName,      // REQUIRED - lay tu current user profile
    required String receiverPhone,
    required String lockerId,
    required int slotIndex,
    required String packageSize,
  }) async {
    final res = await _client.post(ApiEndpoints.deliveryRequests, data: {
      'senderName': senderName,
      'receiverPhone': receiverPhone,
      'lockerId': lockerId,
      'slotIndex': slotIndex,
      'packageSize': packageSize,
    });
    return DeliveryRequestModel.fromJson(res.data);
  }

  @override
  Future<List<DeliveryRequest>> getMyRequests() async {
    final res = await _client.get(ApiEndpoints.deliveryRequestsMy);
    return (res.data as List)
        .map((e) => DeliveryRequestModel.fromJson(e))
        .toList();
  }

  @override
  Future<DeliveryRequest> trackDelivery(String trackingCode) async {
    final res = await _client.get(ApiEndpoints.deliveryTrack(trackingCode));
    return DeliveryRequestModel.fromJson(res.data);
  }
}
```

### 5c. SendReceiveRepository

```dart
class SendReceiveRepository implements ISendReceiveRepository {
  final _client = ApiClient().client;

  @override
  Future<SendReceiveOrder> createOrder({
    required String lockerId,
    required int slotIndex,
    required String receiverPhone,
    required String pinCode,      // REQUIRED
    String? notes,
  }) async {
    final res = await _client.post(ApiEndpoints.sendReceiveOrders, data: {
      'lockerId': lockerId,
      'slotIndex': slotIndex,
      'receiverPhone': receiverPhone,
      'pinCode': pinCode,
      if (notes != null) 'notes': notes,
    });
    return SendReceiveOrderModel.fromJson(res.data);
  }

  @override
  Future<List<SendReceiveOrder>> getMyOrders() async {
    final res = await _client.get(ApiEndpoints.sendReceiveOrdersMy);
    return (res.data as List)
        .map((e) => SendReceiveOrderModel.fromJson(e))
        .toList();
  }

  @override
  Future<SendReceiveOrder> getOrderById(String id) async {
    final res = await _client.get(ApiEndpoints.sendReceiveOrderById(id));
    return SendReceiveOrderModel.fromJson(res.data);
  }

  @override
  Future<void> confirmOrder(String id) async {
    await _client.patch(ApiEndpoints.sendReceiveOrderConfirm(id));
  }

  @override
  Future<void> completeOrder(String id) async {
    await _client.patch(ApiEndpoints.sendReceiveOrderComplete(id));
  }
}
```

### 5d. WalletRepository

```dart
class WalletRepository implements IWalletRepository {
  final _client = ApiClient().client;

  @override
  Future<WalletOverview> getOverview() async {
    final res = await _client.get(ApiEndpoints.walletOverview);
    return WalletOverviewModel.fromJson(res.data);
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    final res = await _client.get(ApiEndpoints.walletTransactions);
    return (res.data as List)
        .map((e) => WalletTransactionModel.fromJson(e))
        .toList();
  }

  @override
  Future<double> getBalance() async {
    final res = await _client.get(ApiEndpoints.walletBalance);
    return (res.data['balance'] as num).toDouble();
  }

  @override
  Future<void> topUp(double amount, {String? referenceId}) async {
    await _client.post(ApiEndpoints.walletTopUp, data: {
      'amount': amount,
      if (referenceId != null) 'referenceId': referenceId,
    });
  }

  @override
  Future<void> transfer(String receiverId, double amount, {String? note}) async {
    await _client.post(ApiEndpoints.walletTransfer, data: {
      'receiverId': receiverId,
      'amount': amount,
      if (note != null) 'note': note,
    });
  }

  @override
  Future<Map<String, dynamic>> initVnPayTopUp(double amount) async {
    final res = await _client.post(ApiEndpoints.walletTopUpVnPayInit, data: {
      'amount': amount,
    });
    return res.data;
  }
}
```

### 5e. OrderRepository - Full Flow

```dart
class OrderRepository implements IOrderRepository {
  final _client = ApiClient().client;

  Future<OrderReservationResult> reserveSlot({
    required String lockerId,
    required int slotIndex,
    required String packageId,
    required DateTime checkInTime,
    required int durationHours,
    required String mobileNumber,
    String? notes,
  }) async {
    final res = await _client.post(ApiEndpoints.ordersReserve, data: {
      'lockerId': lockerId,
      'slotIndex': slotIndex,
      'packageId': packageId,
      'checkInTime': checkInTime.toIso8601String(),
      'durationHours': durationHours,
      'mobileNumber': mobileNumber,
      if (notes != null) 'notes': notes,
    });
    return OrderReservationResult.fromJson(res.data);
  }

  Future<PaymentDto> createPayment({
    required String bookingId,
    required String method,
  }) async {
    final res = await _client.post(ApiEndpoints.payments, data: {
      'bookingId': bookingId,
      'method': method,
    });
    return PaymentDto.fromJson(res.data);
  }

  Future<OrderDto> confirmOrder(String id, {String? notes}) async {
    final res = await _client.patch(ApiEndpoints.orderConfirm(id), data: {
      if (notes != null) 'notes': notes,
    });
    return OrderDto.fromJson(res.data);
  }

  Future<OrderDto> activateOrder(String id) async {
    // NO body required
    final res = await _client.patch(ApiEndpoints.orderActivate(id));
    return OrderDto.fromJson(res.data);
  }

  Future<OrderDto> completeOrder(String id, {String? notes}) async {
    final res = await _client.patch(ApiEndpoints.orderComplete(id), data: {
      if (notes != null) 'notes': notes,
    });
    return OrderDto.fromJson(res.data);
  }

  Future<OrderDto> cancelOrder(String id, {String? reason}) async {
    final res = await _client.patch(ApiEndpoints.orderCancel(id), data: {
      if (reason != null) 'cancellationReason': reason,
    });
    return OrderDto.fromJson(res.data);
  }

  Future<OrderDto> extendOrder(String id, int additionalHours) async {
    final res = await _client.post(ApiEndpoints.orderExtend(id), data: {
      'additionalHours': additionalHours,
    });
    return OrderDto.fromJson(res.data);
  }

  Future<List<OrderDto>> getMyOrders({String? status}) async {
    final res = await _client.get(ApiEndpoints.ordersMy, queryParameters: {
      if (status != null) 'status': status,
    });
    return (res.data as List).map((e) => OrderDto.fromJson(e)).toList();
  }
}
```

---

## 6. UI Flows - Step by Step

### Luong 1: Register & Auto-Login

```text
1. POST /api/auth/register
   Body: { username, email, password, fullName?, phoneNumber? }
   -> 200: { token, refreshToken, username, role, expiresAt }
2. Luu token vao SecureStorage
3. ApiClient.setToken(token)
4. GET /api/users/me -> user profile
5. Chuyen huong sang HomeScreen
```

### Luong 2: Dat Locker (Order)

```text
1. GET /api/packages -> danh sach goi
2. GET /api/lockers/available -> locker trong
3. POST /api/orders/reserve
   Body: { lockerId, slotIndex, packageId, checkInTime, durationHours, mobileNumber, notes? }
   -> 201: { orderId, status: "Initiated", totalAmount, expirationTime }
4. POST /api/payments
   Body: { bookingId: orderId, method: "Wallet|VnPay|MoMo" }
   -> 201: PaymentDto { id, status: "Pending" }
5. [Payment tu VnPay/MoMo webhook -> Payment status = Completed]
6. PATCH /api/orders/{orderId}/confirm
   Body: { notes? }
   -> 200: OrderDto { status: "Reserved" }
7. PATCH /api/orders/{orderId}/activate
   (NO body)
   -> 200: OrderDto { status: "Active" }
8. POST /api/lockers/{lockerId}/open
   Body: { slotIndex, reason? }
   -> 204
9. PATCH /api/orders/{orderId}/complete
   Body: { notes? }
   -> 200: OrderDto { status: "Completed" }
```

### Luong 3: Send/Receive

```text
1. GET /api/lockers/available
2. User chon locker + slot
3. POST /api/send-receive/orders
   Body: { lockerId, slotIndex, receiverPhone, pinCode, notes? }
   -> 200: SendReceiveOrderDto
4. GET /api/send-receive/orders/my -> lich su
5. PATCH /api/send-receive/orders/{id}/confirm (NO body)
   -> 200
6. PATCH /api/send-receive/orders/{id}/complete (NO body)
   -> 200
```

### Luong 4: Food Order

```text
1. GET /api/restaurants -> danh sach nha hang
2. GET /api/restaurants/{id}/menu -> menu
3. User chon mon + so luong
4. GET /api/lockers/available -> chon locker giao
5. POST /api/food-orders
   Body: { restaurantId, lockerId, slotIndex, items: [{menuItemId, quantity, notes?}], deliveryNotes? }
   -> 200: FoodOrderDto + Payment (tu dong tao, status = Pending)
6. [Thanh toan] -> Payment status = Completed
7. GET /api/food-orders/my -> lich su
```

### Luong 5: Delivery

```text
1. GET /api/delivery/package-sizes -> ["Small", "Medium", "Large"]
2. GET /api/lockers/available -> chon locker
3. POST /api/delivery/requests
   Body: { senderName: currentUser.fullName, receiverPhone, lockerId, slotIndex, packageSize }
   -> 200: DeliveryRequestDto { trackingCode }
4. GET /api/delivery/requests/my -> lich su
5. GET /api/delivery/requests/track/{trackingCode} -> chi tiet (khong can auth)
```

### Luong 6: Wallet

```text
1. GET /api/wallet/overview
   -> { balance, recentTransactionsCount }
2. GET /api/wallet/transactions
   -> [{ id, amount, type, status, description, createdAt }]
3. POST /api/wallet/top-up
   Body: { amount, referenceId? }
4. POST /api/wallet/top-up/vnpay/init
   Body: { amount }
   -> { paymentUrl }
   [Chuyen huong sang VnPay]
5. GET /api/wallet/top-up/vnpay/return
   [VnPay callback]
6. POST /api/wallet/transfer
   Body: { receiverId, amount, note? }
```

---

## 7. File Tree

```
mobile/lib/
+ core/constants/api_endpoints.dart              [Sua - them tat ca endpoints]
+ features/auth/
  + data/auth_repository.dart                   [Sua - loginWithToken]
  + domain/repositories/i_auth_repository.dart  [Sua - them method]
+ features/sign_up/
  + data/sign_up_repository.dart               [Sua - parse AuthResponse]
  + presentation/cubits/sign_up_cubit.dart     [Sua - auto-login]
+ features/wallet/
  + domain/entities/wallet_overview.dart       [Sua - BO transactions]
  + domain/entities/wallet_transaction.dart   [Sua - type mapping]
  + data/models/wallet_overview_model.dart    [Sua - fromJson]
  + data/models/wallet_transaction_model.dart [Sua - fromJson]
  + data/wallet_repository.dart               [Sua - real API]
+ features/food_order/
  + domain/entities/restaurant.dart           [Tao moi]
  + domain/entities/menu_item.dart            [Tao moi]
  + domain/entities/food_order.dart           [Sua - them lockerId, slotIndex]
  + data/models/restaurant_model.dart         [Tao moi]
  + data/models/menu_item_model.dart          [Tao moi]
  + data/models/food_order_model.dart        [Tao/Sua]
  + data/food_order_repository.dart           [Sua - real API]
+ features/delivery/
  + domain/entities/delivery_request.dart     [Sua - senderName required]
  + data/models/delivery_request_model.dart   [Tao/Sua]
  + data/delivery_repository.dart             [Sua - senderName required]
+ features/send_receive/
  + domain/entities/send_receive_order.dart    [Sua - BO pinCode]
  + data/models/send_receive_order_model.dart [Sua - fromJson]
  + data/send_receive_repository.dart        [Sua - real API]
+ features/orders/
  + data/orders_repository.dart               [Sua - full flow]
+ features/locker/
  + data/locker_repository.dart              [Sua - them endpoints]
```

---

## 8. Enum Mapping

```dart
// Order Status
enum OrderStatusEnum {
  initiated, reserved, paid, active, completed, cancelled
}

// Food Order Status
enum FoodOrderStatusEnum {
  paymentRequired, pending, preparing, delivering,
  deliveredToLocker, completed, cancelled
}

// Send/Receive Status
enum SendReceiveStatusEnum {
  initiated, deposited, received, cancelled
}

// Delivery Status
enum DeliveryStatusEnum {
  pending, deliveredToLocker, completed, cancelled
}

// Transaction Type
enum TransactionTypeEnum {
  topUp, transfer, payment, refund
}

// Transaction Status
enum TransactionStatusEnum {
  pending, completed, failed
}

T mapStatus<T>(String? value, Map<String, T> mapping, T defaultValue) {
  if (value == null) return defaultValue;
  return mapping[value] ?? defaultValue;
}
```

---

## 9. Trinh Tu Thuc Hien

1. Cap nhat `api_endpoints.dart` - them tat ca endpoints
2. Cap nhat Auth flow - register tra ve AuthResponse
3. Tao entity/model files moi (Restaurant, MenuItem, FoodOrder)
4. Cap nhat Wallet entities/models - dung backend contracts
5. Cap nhat Delivery entities - senderName required
6. Cap nhat SendReceive entities - dung backend contracts
7. Viet lai repositories voi real API
8. Cap nhat Order repository - full flow (reserve -> payment -> confirm -> activate -> complete)
9. Cap nhat UI Cubits/BLoCs de su dung repository moi
10. Test tat ca luong API

---

## 10. Ghi Chu Quan Trong

- **Restaurants**: `[Authorize]` - can co token
- **Confirm order**: Co body `{ notes? }`
- **Activate order**: KHONG co body
- **Send/Receive confirm/complete**: KHONG co body
- **Wallet overview**: KHONG co transactions - goi rieng
- **Food order**: Tu dong tao Payment pending
- **Delivery**: `senderName` lay tu current user profile
- Tat ca Guid fields -> String trong Flutter
- decimal fields -> double trong Flutter
