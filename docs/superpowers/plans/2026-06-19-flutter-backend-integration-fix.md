# Flutter Backend Integration Fix Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix cac loi nghiep vu nghiem trong trong Flutter app -- sign_up response parsing, auto-login, wallet real API, food_order real API, delivery/send_receive entities.

**Architecture:** Fix theo thu tu uu tien: Critical (Sign Up) -> High (Wallet) -> High (Food Order) -> Medium (Delivery/Send Receive) -> Medium (Locker/Orders/Profile endpoints). Cac repository se goi real API thong qua ApiClient, entities/models map dung backend DTOs.

**Tech Stack:** Flutter, Dart, Dio, flutter_bloc (Cubit), SharedPreferences

---

## Task 1: Fix Sign Up - Response Parsing + Auto-Login

**Files:**
- Modify: `mobile/lib/features/sign_up/domain/entities/sign_up_request.dart`
- Modify: `mobile/lib/features/sign_up/data/models/sign_up_model.dart`
- Modify: `mobile/lib/features/sign_up/data/sign_up_repository.dart`
- Modify: `mobile/lib/features/sign_up/presentation/controllers/sign_up_cubit.dart`
- Modify: `mobile/lib/features/auth/domain/repositories/i_auth_repository.dart`
- Modify: `mobile/lib/core/constants/api_endpoints.dart`

### Step 1.1: Sua AuthResponse model

- [ ] **Step 1.1.1: Tao AuthResponse entity**

Tao file moi `mobile/lib/features/auth/domain/entities/auth_response.dart`:

```dart
class AuthResponse {
  final String token;
  final String refreshToken;
  final String username;
  final String role;
  final DateTime expiresAt;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.username,
    required this.role,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
```

- [ ] **Step 1.1.2: Them AuthResponse vao index**

Them vao `mobile/lib/features/auth/domain/entities/index.dart` (neu co):

```dart
export 'auth_response.dart';
```

### Step 1.2: Sua SignUpResponse entity

- [ ] **Step 1.2.1: Sua SignUpResponse**

Thay noi dung `mobile/lib/features/sign_up/domain/entities/sign_up_request.dart`:

```dart
// SIGN UP: gui request
class SignUpRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;

  SignUpRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
  });
}

// SIGN UP: backend tra ve AuthResponse
// SignUpResponse chi la wrapper chua AuthResponse
class SignUpResponse {
  final AuthResponse auth;

  SignUpResponse({required this.auth});
}
```

### Step 1.3: Sua SignUpRequestModel

- [ ] **Step 1.3.1: Sua SignUpRequestModel.toJson()**

Sua `mobile/lib/features/sign_up/data/models/sign_up_model.dart` - method `toJson()`:

```dart
Map<String, dynamic> toJson() {
  return {
    'username': email, // Backend dung username = email
    'email': email,
    'fullName': fullName,
    'password': password,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
  };
}
```

### Step 1.4: Sua SignUpResponseModel

- [ ] **Step 1.4.1: Sua SignUpResponseModel**

Thay doi `mobile/lib/features/sign_up/data/models/sign_up_model.dart` - class `SignUpResponseModel`:

```dart
import '../../../auth/domain/entities/auth_response.dart' show AuthResponse;

class SignUpResponseModel extends SignUpResponse {
  SignUpResponseModel({required AuthResponse auth}) : super(auth: auth);

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel(
      auth: AuthResponse.fromJson(json),
    );
  }
}
```

### Step 1.5: Sua SignUpRepository

- [ ] **Step 1.5.1: Parse response tu backend**

Sua `mobile/lib/features/sign_up/data/sign_up_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/sign_up_request.dart' show SignUpRequest, SignUpResponse;
import '../domain/repositories/i_sign_up_repository.dart';
import 'models/sign_up_model.dart';

class SignUpRepository implements ISignUpRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.authRegister,
        data: SignUpRequestModel(
          fullName: request.fullName,
          email: request.email,
          password: request.password,
          phoneNumber: request.phoneNumber,
        ).toJson(),
      );

      // Backend tra 200 hoac 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SignUpResponseModel.fromJson(response.data);
      }

      throw NetworkException('Đăng ký thất bại. Vui lòng thử lại sau.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw AppException('Email đã tồn tại. Vui lòng sử dụng email khác.');
      }
      throw NetworkException(e.message ?? 'Lỗi mạng khi đăng ký');
    } catch (e) {
      throw AppException('Đăng ký thất bại: $e');
    }
  }
}
```

### Step 1.6: Them loginWithToken vao IAuthRepository

- [ ] **Step 1.6.1: Them method vao interface**

Sua `mobile/lib/features/auth/domain/repositories/i_auth_repository.dart`:

```dart
abstract class IAuthRepository {
  Future<bool> login(String username, String password);
  Future<void> loginWithToken(String token, String refreshToken);
  Future<void> refreshToken();
  Future<bool> checkLoginStatus();
  Future<void> logout({bool callServer = true});
  Future<void> resendVerificationEmail(String email);
}
```

### Step 1.7: Sua SignUpCubit - Auto-Login

- [ ] **Step 1.7.1: Inject AuthRepository vao SignUpCubit**

Sua `mobile/lib/features/sign_up/presentation/controllers/sign_up_cubit.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/auth_repository.dart' show AuthRepository;
import '../../domain/entities/sign_up_request.dart' show SignUpRequest;
import '../../domain/usecases/sign_up_usecase.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final SignUpUseCase signUpUseCase;
  final AuthRepository _authRepository;

  SignUpCubit({
    required this.signUpUseCase,
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(SignUpState());

  void setFullName(String name) {
    emit(state.copyWith(fullName: name));
  }

  void setEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void setPassword(String password) {
    emit(state.copyWith(password: password));
  }

  Future<void> signUp() async {
    if (!_validateInputs()) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final request = SignUpRequest(
        fullName: state.fullName,
        email: state.email,
        password: state.password,
        phoneNumber: state.phoneNumber?.isNotEmpty == true ? state.phoneNumber : null,
      );

      final response = await signUpUseCase(request);

      // Auto-login bang token tu backend
      final auth = response.auth;
      await _authRepository.loginWithToken(auth.token, auth.refreshToken);

      emit(state.copyWith(
        isLoading: false,
        response: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Đăng ký thất bại: ${e.toString()}',
      ));
    }
  }

  bool _validateInputs() {
    if (state.fullName.isEmpty) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập họ và tên'));
      return false;
    }
    if (state.email.isEmpty || !_isValidEmail(state.email)) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập email hợp lệ'));
      return false;
    }
    if (state.password.isEmpty || state.password.length < 6) {
      emit(state.copyWith(errorMessage: 'Mật khẩu phải có ít nhất 6 ký tự'));
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
```

### Step 1.8: Sua SignUpState

- [ ] **Step 1.8.1: Them phoneNumber field**

Sua `mobile/lib/features/sign_up/presentation/controllers/sign_up_state.dart`:

```dart
import '../../domain/entities/sign_up_request.dart' show SignUpResponse;

class SignUpState {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;
  final bool isLoading;
  final String? errorMessage;
  final SignUpResponse? response;

  SignUpState({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.phoneNumber,
    this.isLoading = false,
    this.errorMessage,
    this.response,
  });

  SignUpState copyWith({
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    bool? isLoading,
    String? errorMessage,
    SignUpResponse? response,
  }) {
    return SignUpState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      response: response ?? this.response,
    );
  }
}
```

### Step 1.9: Sua SignUpScreen

- [ ] **Step 1.9.1: Them phone number field vao UI**

Sua `mobile/lib/features/sign_up/presentation/screens/sign_up_screen.dart`:
- Them `_phoneController` va `_buildPhoneField()`
- Them `context.read<SignUpCubit>().setPhoneNumber(value)` onChanged
- Nut Sign Up tiep tuc nhu cu

### Step 1.10: Commit

```bash
git add mobile/lib/features/sign_up/ mobile/lib/features/auth/domain/repositories/i_auth_repository.dart
git commit -m "fix: parse AuthResponse from register API and auto-login"
```

---

## Task 2: Implement Wallet Real API

**Files:**
- Modify: `mobile/lib/features/wallet/domain/entities/wallet_overview.dart`
- Modify: `mobile/lib/features/wallet/domain/entities/wallet_transaction.dart`
- Modify: `mobile/lib/features/wallet/data/models/wallet_overview_model.dart`
- Modify: `mobile/lib/features/wallet/data/models/wallet_transaction_model.dart`
- Modify: `mobile/lib/features/wallet/data/wallet_repository.dart`
- Modify: `mobile/lib/features/wallet/domain/repositories/i_wallet_repository.dart`
- Modify: `mobile/lib/features/wallet/presentation/cubits/wallet_cubit.dart` (neu co)

### Step 2.1: Sua WalletOverview entity

- [ ] **Step 2.1.1: Sua entity cho dung backend contract**

Thay noi dung `mobile/lib/features/wallet/domain/entities/wallet_overview.dart`:

```dart
class WalletOverview {
  final double balance;
  final int recentTransactionsCount;

  const WalletOverview({
    required this.balance,
    required this.recentTransactionsCount,
  });
}
```

### Step 2.2: Sua WalletTransaction entity

- [ ] **Step 2.2.1: Sua entity cho dung backend contract**

Thay noi dung `mobile/lib/features/wallet/domain/entities/wallet_transaction.dart`:

```dart
class WalletTransaction {
  final String id;
  final double amount;
  final String type;         // topUp, transfer, payment, refund
  final String status;       // pending, completed, failed
  final String? description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    required this.createdAt,
  });
}
```

### Step 2.3: Sua WalletOverviewModel

- [ ] **Step 2.3.1: Map dung backend response**

Thay noi dung `mobile/lib/features/wallet/data/models/wallet_overview_model.dart`:

```dart
import '../../domain/entities/wallet_overview.dart';

class WalletOverviewModel extends WalletOverview {
  const WalletOverviewModel({
    required super.balance,
    required super.recentTransactionsCount,
  });

  factory WalletOverviewModel.fromJson(Map<String, dynamic> json) {
    return WalletOverviewModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      recentTransactionsCount: (json['recentTransactionsCount'] as num?)?.toInt() ?? 0,
    );
  }
}
```

### Step 2.4: Sua WalletTransactionModel

- [ ] **Step 2.4.1: Map dung backend response**

Thay noi dung `mobile/lib/features/wallet/data/models/wallet_transaction_model.dart`:

```dart
import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.status,
    super.description,
    required super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      description: json['description'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
```

### Step 2.5: Mo rong IWalletRepository interface

- [ ] **Step 2.5.1: Them tat ca wallet methods**

Thay noi dung `mobile/lib/features/wallet/domain/repositories/i_wallet_repository.dart`:

```dart
import '../entities/wallet_overview.dart';
import '../entities/wallet_transaction.dart';

abstract class IWalletRepository {
  Future<WalletOverview> getWalletOverview();
  Future<List<WalletTransaction>> getTransactions();
  Future<double> getBalance();
  Future<void> topUp(double amount, {String? referenceId});
  Future<void> transfer(String receiverId, double amount, {String? note});
  Future<Map<String, dynamic>> initVnPayTopUp(double amount);
}
```

### Step 2.6: Viet lai WalletRepository

- [ ] **Step 2.6.1: Replace mock data voi real API calls**

Thay noi dung `mobile/lib/features/wallet/data/wallet_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/wallet_overview.dart';
import '../domain/entities/wallet_transaction.dart';
import '../domain/repositories/i_wallet_repository.dart';
import 'models/wallet_overview_model.dart';
import 'models/wallet_transaction_model.dart';

class WalletRepository implements IWalletRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<WalletOverview> getWalletOverview() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.walletOverview);
      if (response.statusCode == 200) {
        return WalletOverviewModel.fromJson(response.data);
      }
      throw NetworkException('Không thể tải thông tin ví');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải thông tin ví');
    } catch (e) {
      throw AppException('Lỗi khi tải thông tin ví: $e');
    }
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.walletTransactions);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải lịch sử giao dịch');
    } catch (e) {
      throw AppException('Lỗi khi tải lịch sử giao dịch: $e');
    }
  }

  @override
  Future<double> getBalance() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.walletBalance);
      if (response.statusCode == 200) {
        return (response.data['balance'] as num).toDouble();
      }
      throw NetworkException('Không thể tải số dư');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải số dư');
    } catch (e) {
      throw AppException('Lỗi khi tải số dư: $e');
    }
  }

  @override
  Future<void> topUp(double amount, {String? referenceId}) async {
    try {
      await _apiClient.client.post(ApiEndpoints.walletTopUp, data: {
        'amount': amount,
        if (referenceId != null) 'referenceId': referenceId,
      });
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi nạp tiền');
    } catch (e) {
      throw AppException('Lỗi khi nạp tiền: $e');
    }
  }

  @override
  Future<void> transfer(String receiverId, double amount, {String? note}) async {
    try {
      await _apiClient.client.post(ApiEndpoints.walletTransfer, data: {
        'receiverId': receiverId,
        'amount': amount,
        if (note != null) 'note': note,
      });
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi chuyển tiền');
    } catch (e) {
      throw AppException('Lỗi khi chuyển tiền: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> initVnPayTopUp(double amount) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.walletTopUpVnPayInit,
        data: {'amount': amount},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw NetworkException('Không thể khởi tạo thanh toán VNPay');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi khởi tạo VNPay');
    } catch (e) {
      throw AppException('Lỗi khi khởi tạo thanh toán: $e');
    }
  }
}
```

### Step 2.7: Commit

```bash
git add mobile/lib/features/wallet/
git commit -m "feat: implement wallet real API with correct backend contracts"
```

---

## Task 3: Implement Food Order Real API

**Files:**
- Create: `mobile/lib/features/food_order/domain/entities/restaurant.dart`
- Create: `mobile/lib/features/food_order/domain/entities/food_order.dart`
- Modify: `mobile/lib/features/food_order/domain/entities/menu_item.dart` (neu co)
- Create: `mobile/lib/features/food_order/data/models/restaurant_model.dart`
- Create: `mobile/lib/features/food_order/data/models/food_order_model.dart`
- Modify: `mobile/lib/features/food_order/data/models/menu_item_model.dart` (neu co)
- Modify: `mobile/lib/features/food_order/domain/repositories/i_food_order_repository.dart`
- Modify: `mobile/lib/features/food_order/data/food_order_repository.dart`

### Step 3.1: Tao Restaurant entity

- [ ] **Step 3.1.1: Tao restaurant.dart**

Tao file moi `mobile/lib/features/food_order/domain/entities/restaurant.dart`:

```dart
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String imageUrl;
  final double rating;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.imageUrl,
    required this.rating,
  });
}
```

### Step 3.2: Tao FoodOrder entity

- [ ] **Step 3.2.1: Tao food_order.dart**

Tao file moi `mobile/lib/features/food_order/domain/entities/food_order.dart`:

```dart
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

  const FoodOrder({
    required this.id,
    required this.restaurantId,
    required this.lockerId,
    required this.slotIndex,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.deliveryNotes,
    required this.createdAt,
  });
}

class FoodOrderItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String? notes;

  const FoodOrderItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });
}
```

### Step 3.3: Mo rong MenuItem entity

- [ ] **Step 3.3.1: Them category + isAvailable**

Sua `mobile/lib/features/menu/domain/entities/menu_item.dart` (hoac tao copy tai `mobile/lib/features/food_order/domain/entities/menu_item.dart`):

```dart
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
  });
}
```

### Step 3.4: Tao RestaurantModel

- [ ] **Step 3.4.1: Tao restaurant_model.dart**

Tao file moi `mobile/lib/features/food_order/data/models/restaurant_model.dart`:

```dart
import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.description,
    required super.address,
    required super.imageUrl,
    required super.rating,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
```

### Step 3.5: Tao FoodOrderModel

- [ ] **Step 3.5.1: Tao food_order_model.dart**

Tao file moi `mobile/lib/features/food_order/data/models/food_order_model.dart`:

```dart
import '../../domain/entities/food_order.dart';

class FoodOrderModel extends FoodOrder {
  const FoodOrderModel({
    required super.id,
    required super.restaurantId,
    required super.lockerId,
    required super.slotIndex,
    required super.items,
    required super.totalAmount,
    required super.status,
    super.deliveryNotes,
    required super.createdAt,
  });

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
              .toList() ??
          [],
    );
  }
}

class FoodOrderItemModel extends FoodOrderItem {
  const FoodOrderItemModel({
    required super.menuItemId,
    required super.name,
    required super.quantity,
    required super.unitPrice,
    super.notes,
  });

  factory FoodOrderItemModel.fromJson(Map<String, dynamic> json) {
    return FoodOrderItemModel(
      menuItemId: json['menuItemId'].toString(),
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'quantity': quantity,
      if (notes != null) 'notes': notes,
    };
  }
}
```

### Step 3.6: Mo rong IFoodOrderRepository

- [ ] **Step 3.6.1: Them tat ca food order methods**

Thay noi dung `mobile/lib/features/food_order/domain/repositories/i_food_order_repository.dart`:

```dart
import '../entities/restaurant.dart';
import '../entities/menu_item.dart' show MenuItem;
import '../entities/food_order.dart' show FoodOrder;

abstract class IFoodOrderRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<Restaurant> getRestaurantById(String id);
  Future<List<MenuItem>> getMenu(String restaurantId);
  Future<FoodOrder> createFoodOrder({
    required String restaurantId,
    required String lockerId,
    required int slotIndex,
    required List<Map<String, dynamic>> items,
    String? deliveryNotes,
  });
  Future<List<FoodOrder>> getMyOrders();
  Future<FoodOrder> getOrderById(String id);
}
```

### Step 3.7: Viet lai FoodOrderRepository

- [ ] **Step 3.7.1: Replace mock data voi real API**

Thay noi dung `mobile/lib/features/food_order/data/food_order_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/restaurant.dart';
import '../domain/entities/menu_item.dart' show MenuItem;
import '../domain/entities/food_order.dart' show FoodOrder;
import '../domain/repositories/i_food_order_repository.dart';
import 'models/restaurant_model.dart';
import 'models/menu_item_model.dart';
import 'models/food_order_model.dart';

class FoodOrderRepository implements IFoodOrderRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.restaurants);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải danh sách nhà hàng');
    } catch (e) {
      throw AppException('Lỗi khi tải danh sách nhà hàng: $e');
    }
  }

  @override
  Future<Restaurant> getRestaurantById(String id) async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.restaurantById(id));
      if (response.statusCode == 200) {
        return RestaurantModel.fromJson(response.data);
      }
      throw NetworkException('Không tìm thấy nhà hàng');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải thông tin nhà hàng');
    } catch (e) {
      throw AppException('Lỗi khi tải thông tin nhà hàng: $e');
    }
  }

  @override
  Future<List<MenuItem>> getMenu(String restaurantId) async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.restaurantMenu(restaurantId));
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải menu');
    } catch (e) {
      throw AppException('Lỗi khi tải menu: $e');
    }
  }

  @override
  Future<FoodOrder> createFoodOrder({
    required String restaurantId,
    required String lockerId,
    required int slotIndex,
    required List<Map<String, dynamic>> items,
    String? deliveryNotes,
  }) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.foodOrders,
        data: {
          'restaurantId': restaurantId,
          'lockerId': lockerId,
          'slotIndex': slotIndex,
          'items': items,
          if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
        },
      );
      if (response.statusCode == 200) {
        return FoodOrderModel.fromJson(response.data);
      }
      throw NetworkException('Tạo đơn hàng thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tạo đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi tạo đơn hàng: $e');
    }
  }

  @override
  Future<List<FoodOrder>> getMyOrders() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.foodOrdersMy);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => FoodOrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi tải đơn hàng: $e');
    }
  }

  @override
  Future<FoodOrder> getOrderById(String id) async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.foodOrderById(id));
      if (response.statusCode == 200) {
        return FoodOrderModel.fromJson(response.data);
      }
      throw NetworkException('Không tìm thấy đơn hàng');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi tải đơn hàng: $e');
    }
  }
}
```

### Step 3.8: Tao MenuItemModel (neu chua co)

- [ ] **Step 3.8.1: Tao menu_item_model.dart trong food_order**

Neu `mobile/lib/features/menu/data/models/menu_item_model.dart` chua ton tai, tao file moi:

```dart
import '../../domain/entities/menu_item.dart' show MenuItem;

class MenuItemModel extends MenuItem {
  const MenuItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.category,
    required super.isAvailable,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
```

### Step 3.9: Commit

```bash
git add mobile/lib/features/food_order/
git add mobile/lib/features/menu/data/models/menu_item_model.dart
git commit -m "feat: implement food order real API with restaurant, menu, order entities"
```

---

## Task 4: Implement Delivery Real API + Fix Entities

**Files:**
- Modify: `mobile/lib/features/delivery/domain/entities/delivery_request.dart`
- Modify: `mobile/lib/features/delivery/domain/entities/delivery_package_size.dart`
- Create: `mobile/lib/features/delivery/data/models/delivery_request_model.dart`
- Modify: `mobile/lib/features/delivery/domain/repositories/i_delivery_repository.dart`
- Modify: `mobile/lib/features/delivery/data/delivery_repository.dart`

### Step 4.1: Sua DeliveryRequest entity

- [ ] **Step 4.1.1: Tao dung backend contract**

Thay noi dung `mobile/lib/features/delivery/domain/entities/delivery_request.dart`:

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

  const DeliveryRequest({
    required this.id,
    required this.senderName,
    required this.receiverPhone,
    required this.lockerId,
    required this.slotIndex,
    required this.packageSize,
    required this.trackingCode,
    required this.status,
    required this.createdAt,
  });
}

// Request gui di
class SendDeliveryRequest {
  final String senderName;
  final String receiverPhone;
  final String lockerId;
  final int slotIndex;
  final String packageSize;

  const SendDeliveryRequest({
    required this.senderName,
    required this.receiverPhone,
    required this.lockerId,
    required this.slotIndex,
    required this.packageSize,
  });
}
```

### Step 4.2: Sua DeliveryPackageSize entity

- [ ] **Step 4.2.1: Chi giu nhung field backend tra ve**

Thay noi dung `mobile/lib/features/delivery/domain/entities/delivery_package_size.dart`:

```dart
class DeliveryPackageSize {
  final String size; // Small, Medium, Large

  const DeliveryPackageSize({required this.size});
}
```

### Step 4.3: Tao DeliveryRequestModel

- [ ] **Step 4.3.1: Map dung backend response**

Tao file moi `mobile/lib/features/delivery/data/models/delivery_request_model.dart`:

```dart
import '../../domain/entities/delivery_request.dart';

class DeliveryRequestModel extends DeliveryRequest {
  const DeliveryRequestModel({
    required super.id,
    required super.senderName,
    required super.receiverPhone,
    required super.lockerId,
    required super.slotIndex,
    required super.packageSize,
    required super.trackingCode,
    required super.status,
    required super.createdAt,
  });

  factory DeliveryRequestModel.fromJson(Map<String, dynamic> json) {
    return DeliveryRequestModel(
      id: json['id'].toString(),
      senderName: json['senderName'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      lockerId: json['lockerId'].toString(),
      slotIndex: json['slotIndex'] as int? ?? 0,
      packageSize: json['packageSize'] as String? ?? '',
      trackingCode: json['trackingCode'] as String? ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
```

### Step 4.4: Mo rong IDeliveryRepository

- [ ] **Step 4.4.1: Them tat ca delivery methods**

Thay noi dung `mobile/lib/features/delivery/domain/repositories/i_delivery_repository.dart`:

```dart
import '../entities/delivery_package_size.dart';
import '../entities/delivery_request.dart';

abstract class IDeliveryRepository {
  Future<List<DeliveryPackageSize>> getPackageSizes();
  Future<DeliveryRequest> createSendRequest(SendDeliveryRequest request);
  Future<List<DeliveryRequest>> getMyRequests();
  Future<DeliveryRequest> trackDelivery(String trackingCode);
  Future<String> submitReceiveCode(String code);
}
```

### Step 4.5: Viet lai DeliveryRepository

- [ ] **Step 4.5.1: Replace mock data voi real API**

Thay noi dung `mobile/lib/features/delivery/data/delivery_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/delivery_package_size.dart';
import '../domain/entities/delivery_request.dart';
import '../domain/repositories/i_delivery_repository.dart';
import 'models/delivery_request_model.dart';

class DeliveryRepository implements IDeliveryRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<DeliveryPackageSize>> getPackageSizes() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.deliveryPackageSizes);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => DeliveryPackageSize(size: e as String))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải kích thước gói hàng');
    } catch (e) {
      throw AppException('Lỗi khi tải kích thước gói hàng: $e');
    }
  }

  @override
  Future<DeliveryRequest> createSendRequest(SendDeliveryRequest request) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.deliveryRequests,
        data: {
          'senderName': request.senderName,
          'receiverPhone': request.receiverPhone,
          'lockerId': request.lockerId,
          'slotIndex': request.slotIndex,
          'packageSize': request.packageSize,
        },
      );
      if (response.statusCode == 200) {
        return DeliveryRequestModel.fromJson(response.data);
      }
      throw NetworkException('Tạo yêu cầu giao hàng thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tạo yêu cầu giao hàng');
    } catch (e) {
      throw AppException('Lỗi khi tạo yêu cầu giao hàng: $e');
    }
  }

  @override
  Future<List<DeliveryRequest>> getMyRequests() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.deliveryRequestsMy);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => DeliveryRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải lịch sử giao hàng');
    } catch (e) {
      throw AppException('Lỗi khi tải lịch sử giao hàng: $e');
    }
  }

  @override
  Future<DeliveryRequest> trackDelivery(String trackingCode) async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.deliveryTrack(trackingCode));
      if (response.statusCode == 200) {
        return DeliveryRequestModel.fromJson(response.data);
      }
      throw NetworkException('Không tìm thấy thông tin giao hàng');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tra cứu giao hàng');
    } catch (e) {
      throw AppException('Lỗi khi tra cứu giao hàng: $e');
    }
  }

  @override
  Future<String> submitReceiveCode(String code) async {
    // Logic nay tuy backend co hay khong
    // Tam thoi giu nhu cu, hoac goi endpoint tuong ung neu backend co
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return 'Đã xác nhận mã nhận hàng: $code';
  }
}
```

### Step 4.6: Commit

```bash
git add mobile/lib/features/delivery/
git commit -m "feat: implement delivery real API with correct entities"
```

---

## Task 5: Implement Send/Receive Real API + Fix Entities

**Files:**
- Modify: `mobile/lib/features/send_receive/domain/entities/send_receive_order.dart`
- Modify: `mobile/lib/features/send_receive/domain/repositories/i_send_receive_repository.dart`
- Modify: `mobile/lib/features/send_receive/data/send_receive_repository.dart`

### Step 5.1: Sua SendReceiveOrder entity

- [ ] **Step 5.1.1: Tao dung backend contract**

Thay noi dung `mobile/lib/features/send_receive/domain/entities/send_receive_order.dart`:

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

  const SendReceiveOrder({
    required this.id,
    required this.senderId,
    required this.receiverPhone,
    required this.lockerId,
    required this.slotIndex,
    required this.status,
    this.notes,
    required this.createdAt,
  });
}
```

### Step 5.2: Mo rong ISendReceiveRepository

- [ ] **Step 5.2.1: Them send/receive methods day du**

Thay noi dung `mobile/lib/features/send_receive/domain/repositories/i_send_receive_repository.dart`:

```dart
import '../entities/send_receive_order.dart';

abstract class ISendReceiveRepository {
  Future<SendReceiveOrder> createOrder({
    required String lockerId,
    required int slotIndex,
    required String receiverPhone,
    required String pinCode,
    String? notes,
  });
  Future<List<SendReceiveOrder>> getMyOrders();
  Future<SendReceiveOrder> getOrderById(String id);
  Future<void> confirmOrder(String id);
  Future<void> completeOrder(String id);
}
```

### Step 5.3: Viet lai SendReceiveRepository

- [ ] **Step 5.3.1: Replace mock data voi real API**

Thay noi dung `mobile/lib/features/send_receive/data/send_receive_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/send_receive_order.dart';
import '../domain/repositories/i_send_receive_repository.dart';
import 'models/send_receive_order_model.dart';

class SendReceiveRepository implements ISendReceiveRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<SendReceiveOrder> createOrder({
    required String lockerId,
    required int slotIndex,
    required String receiverPhone,
    required String pinCode,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.sendReceiveOrders,
        data: {
          'lockerId': lockerId,
          'slotIndex': slotIndex,
          'receiverPhone': receiverPhone,
          'pinCode': pinCode,
          if (notes != null) 'notes': notes,
        },
      );
      if (response.statusCode == 200) {
        return SendReceiveOrderModel.fromJson(response.data);
      }
      throw NetworkException('Tạo đơn gửi/nhận thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tạo đơn gửi/nhận');
    } catch (e) {
      throw AppException('Lỗi khi tạo đơn gửi/nhận: $e');
    }
  }

  @override
  Future<List<SendReceiveOrder>> getMyOrders() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.sendReceiveOrdersMy);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => SendReceiveOrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải đơn gửi/nhận');
    } catch (e) {
      throw AppException('Lỗi khi tải đơn gửi/nhận: $e');
    }
  }

  @override
  Future<SendReceiveOrder> getOrderById(String id) async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.sendReceiveOrderById(id));
      if (response.statusCode == 200) {
        return SendReceiveOrderModel.fromJson(response.data);
      }
      throw NetworkException('Không tìm thấy đơn gửi/nhận');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải đơn gửi/nhận');
    } catch (e) {
      throw AppException('Lỗi khi tải đơn gửi/nhận: $e');
    }
  }

  @override
  Future<void> confirmOrder(String id) async {
    try {
      await _apiClient.client.patch(ApiEndpoints.sendReceiveOrderConfirm(id));
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi xác nhận đơn');
    } catch (e) {
      throw AppException('Lỗi khi xác nhận đơn: $e');
    }
  }

  @override
  Future<void> completeOrder(String id) async {
    try {
      await _apiClient.client.patch(ApiEndpoints.sendReceiveOrderComplete(id));
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi hoàn tất đơn');
    } catch (e) {
      throw AppException('Lỗi khi hoàn tất đơn: $e');
    }
  }
}
```

### Step 5.4: Tao SendReceiveOrderModel

- [ ] **Step 5.4.1: Map dung backend response**

Tao file moi `mobile/lib/features/send_receive/data/models/send_receive_order_model.dart`:

```dart
import '../../domain/entities/send_receive_order.dart';

class SendReceiveOrderModel extends SendReceiveOrder {
  const SendReceiveOrderModel({
    required super.id,
    required super.senderId,
    required super.receiverPhone,
    required super.lockerId,
    required super.slotIndex,
    required super.status,
    super.notes,
    required super.createdAt,
  });

  factory SendReceiveOrderModel.fromJson(Map<String, dynamic> json) {
    return SendReceiveOrderModel(
      id: json['id'].toString(),
      senderId: json['senderId'].toString(),
      receiverPhone: json['receiverPhone'] as String? ?? '',
      lockerId: json['lockerId'].toString(),
      slotIndex: json['slotIndex'] as int? ?? 0,
      status: json['status']?.toString() ?? '',
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
```

### Step 5.5: Commit

```bash
git add mobile/lib/features/send_receive/
git commit -m "feat: implement send/receive real API with correct entities"
```

---

## Task 6: Fix Locker Repository - Dung ApiEndpoints + Them Methods

**Files:**
- Modify: `mobile/lib/features/locker/domain/repositories/i_locker_repository.dart`
- Modify: `mobile/lib/features/locker/data/locker_repository.dart`

### Step 6.1: Mo rong ILockerRepository

- [ ] **Step 6.1.1: Them locker methods con thieu**

Thay noi dung `mobile/lib/features/locker/domain/repositories/i_locker_repository.dart`:

```dart
import '../entities/locker.dart';

abstract class ILockerRepository {
  Future<List<Locker>> getLockers();
  Future<List<Locker>> getAvailableLockers();
  Future<List<Locker>> getLockerMap();
  Future<Locker> getLockerById(String id);
  Future<void> openLocker(String id, int slotIndex, {String? reason});
}
```

### Step 6.2: Viet lai LockerRepository

- [ ] **Step 6.2.1: Dung ApiEndpoints + them methods**

Thay noi dung `mobile/lib/features/locker/data/locker_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/locker.dart';
import '../domain/repositories/i_locker_repository.dart';
import 'models/locker_model.dart';

class LockerRepository implements ILockerRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<Locker>> getLockers() async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.lockers);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => LockerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải danh sách tủ');
    } catch (e) {
      throw AppException('Lỗi khi tải danh sách tủ: $e');
    }
  }

  @override
  Future<List<Locker>> getAvailableLockers() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.lockersAvailable);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => LockerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải tủ khả dụng');
    } catch (e) {
      throw AppException('Lỗi khi tải tủ khả dụng: $e');
    }
  }

  @override
  Future<List<Locker>> getLockerMap() async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.lockersMap);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => LockerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải bản đồ tủ');
    } catch (e) {
      throw AppException('Lỗi khi tải bản đồ tủ: $e');
    }
  }

  @override
  Future<Locker> getLockerById(String id) async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.lockerById(id));
      if (response.statusCode == 200) {
        return LockerModel.fromJson(response.data);
      }
      throw NetworkException('Không tìm thấy tủ');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải thông tin tủ');
    } catch (e) {
      throw AppException('Lỗi khi tải thông tin tủ: $e');
    }
  }

  @override
  Future<void> openLocker(String id, int slotIndex, {String? reason}) async {
    try {
      await _apiClient.client.post(
        ApiEndpoints.lockerOpen(id),
        data: {
          'slotIndex': slotIndex,
          if (reason != null) 'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi mở tủ');
    } catch (e) {
      throw AppException('Lỗi khi mở tủ: $e');
    }
  }
}
```

### Step 6.3: Commit

```bash
git add mobile/lib/features/locker/
git commit -m "fix: use ApiEndpoints constants and add missing locker methods"
```

---

## Task 7: Implement Orders Full Lifecycle + Profile Entity Fix

**Files:**
- Modify: `mobile/lib/features/orders/domain/repositories/i_orders_repository.dart`
- Modify: `mobile/lib/features/orders/data/orders_repository.dart`
- Modify: `mobile/lib/features/profile/domain/entities/user_profile.dart`
- Modify: `mobile/lib/features/profile/data/profile_repository.dart`

### Step 7.1: Mo rong IOrdersRepository

- [ ] **Step 7.1.1: Them order lifecycle methods**

Thay noi dung `mobile/lib/features/orders/domain/repositories/i_orders_repository.dart`:

```dart
import '../entities/order_history_item.dart';

abstract class IOrdersRepository {
  Future<List<OrderHistoryItem>> getOrders({String? status});
  Future<OrderHistoryItem> getOrderById(String id);
  Future<Map<String, dynamic>> reserveSlot({
    required String lockerId,
    required int slotIndex,
    required String packageId,
    required DateTime checkInTime,
    required int durationHours,
    required String mobileNumber,
    String? notes,
  });
  Future<Map<String, dynamic>> createPayment({
    required String bookingId,
    required String method,
  });
  Future<OrderHistoryItem> confirmOrder(String id, {String? notes});
  Future<OrderHistoryItem> activateOrder(String id);
  Future<OrderHistoryItem> completeOrder(String id, {String? notes});
  Future<OrderHistoryItem> cancelOrder(String id, {String? reason});
  Future<OrderHistoryItem> extendOrder(String id, int additionalHours);
}
```

### Step 7.2: Viet lai OrdersRepository

- [ ] **Step 7.2.1: Implement full order lifecycle**

Thay noi dung `mobile/lib/features/orders/data/orders_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/order_history_item.dart';
import '../domain/repositories/i_orders_repository.dart';

class OrdersRepository implements IOrdersRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<OrderHistoryItem>> getOrders({String? status}) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.ordersMy,
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => _mapOrder(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải lịch sử đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi tải lịch sử đơn hàng: $e');
    }
  }

  @override
  Future<OrderHistoryItem> getOrderById(String id) async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.orderById(id));
      if (response.statusCode == 200) {
        return _mapOrder(response.data as Map<String, dynamic>);
      }
      throw NetworkException('Không tìm thấy đơn hàng');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi tải đơn hàng: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> reserveSlot({
    required String lockerId,
    required int slotIndex,
    required String packageId,
    required DateTime checkInTime,
    required int durationHours,
    required String mobileNumber,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.ordersReserve,
        data: {
          'lockerId': lockerId,
          'slotIndex': slotIndex,
          'packageId': packageId,
          'checkInTime': checkInTime.toIso8601String(),
          'durationHours': durationHours,
          'mobileNumber': mobileNumber,
          if (notes != null) 'notes': notes,
        },
      );
      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw NetworkException('Đặt tủ thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi đặt tủ');
    } catch (e) {
      throw AppException('Lỗi khi đặt tủ: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createPayment({
    required String bookingId,
    required String method,
  }) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.payments,
        data: {
          'bookingId': bookingId,
          'method': method,
        },
      );
      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw NetworkException('Tạo thanh toán thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tạo thanh toán');
    } catch (e) {
      throw AppException('Lỗi khi tạo thanh toán: $e');
    }
  }

  @override
  Future<OrderHistoryItem> confirmOrder(String id, {String? notes}) async {
    try {
      final response = await _apiClient.client.patch(
        ApiEndpoints.orderConfirm(id),
        data: notes != null ? {'notes': notes} : null,
      );
      if (response.statusCode == 200) {
        return _mapOrder(response.data as Map<String, dynamic>);
      }
      throw NetworkException('Xác nhận đơn hàng thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi xác nhận đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi xác nhận đơn hàng: $e');
    }
  }

  @override
  Future<OrderHistoryItem> activateOrder(String id) async {
    try {
      final response =
          await _apiClient.client.patch(ApiEndpoints.orderActivate(id));
      if (response.statusCode == 200) {
        return _mapOrder(response.data as Map<String, dynamic>);
      }
      throw NetworkException('Kích hoạt đơn hàng thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi kích hoạt đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi kích hoạt đơn hàng: $e');
    }
  }

  @override
  Future<OrderHistoryItem> completeOrder(String id, {String? notes}) async {
    try {
      final response = await _apiClient.client.patch(
        ApiEndpoints.orderComplete(id),
        data: notes != null ? {'notes': notes} : null,
      );
      if (response.statusCode == 200) {
        return _mapOrder(response.data as Map<String, dynamic>);
      }
      throw NetworkException('Hoàn tất đơn hàng thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi hoàn tất đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi hoàn tất đơn hàng: $e');
    }
  }

  @override
  Future<OrderHistoryItem> cancelOrder(String id, {String? reason}) async {
    try {
      final response = await _apiClient.client.patch(
        ApiEndpoints.orderCancel(id),
        data: reason != null ? {'cancellationReason': reason} : null,
      );
      if (response.statusCode == 200) {
        return _mapOrder(response.data as Map<String, dynamic>);
      }
      throw NetworkException('Hủy đơn hàng thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi hủy đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi hủy đơn hàng: $e');
    }
  }

  @override
  Future<OrderHistoryItem> extendOrder(String id, int additionalHours) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.orderExtend(id),
        data: {'additionalHours': additionalHours},
      );
      if (response.statusCode == 200) {
        return _mapOrder(response.data as Map<String, dynamic>);
      }
      throw NetworkException('Gia hạn đơn hàng thất bại');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi gia hạn đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi gia hạn đơn hàng: $e');
    }
  }

  OrderHistoryItem _mapOrder(Map<String, dynamic> json) {
    final status = json['status']?.toString().toLowerCase() ?? 'unknown';
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();
    final totalAmount = (json['totalAmount'] as num?)?.toInt() ?? 0;
    final lockerId = json['lockerId']?.toString() ?? '';

    return OrderHistoryItem(
      id: json['id']?.toString() ?? '',
      lockerCode: lockerId,
      title: _titleFromStatus(status),
      location: json['location']?.toString() ?? '',
      status: status,
      createdAt: createdAt,
      amount: totalAmount,
      statusLabel: _statusLabelFromStatus(status),
    );
  }

  String _titleFromStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Đơn hàng hoàn tất';
      case 'pending':
        return 'Đang chờ thanh toán';
      case 'cancelled':
        return 'Đơn hàng bị hủy';
      case 'active':
        return 'Đơn hàng đang thực hiện';
      case 'reserved':
        return 'Đơn hàng đã đặt';
      default:
        return 'Lịch sử truy cập';
    }
  }

  String _statusLabelFromStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn tất';
      case 'pending':
        return 'Chờ thanh toán';
      case 'cancelled':
        return 'Đã hủy';
      case 'active':
        return 'Đang hoạt động';
      case 'reserved':
        return 'Đã đặt';
      default:
        return 'Đang xử lý';
    }
  }
}
```

### Step 7.3: Fix Profile Entity

- [ ] **Step 7.3.1: Chinh sua entity cho dung backend contract**

Sua `mobile/lib/features/profile/domain/entities/user_profile.dart`:

```dart
class UserProfile {
  final String id;
  final String userName;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String role;
  final bool emailConfirmed;

  const UserProfile({
    required this.id,
    required this.userName,
    required this.email,
    this.fullName,
    this.phoneNumber,
    required this.role,
    required this.emailConfirmed,
  });
}
```

Sua `mobile/lib/features/profile/data/profile_repository.dart` - method `getUserProfile()`:

```dart
return UserProfile(
  id: data['id']?.toString() ?? '',
  userName: data['userName']?.toString() ?? data['username']?.toString() ?? '',
  email: data['email']?.toString() ?? '',
  fullName: data['fullName'] as String?,
  phoneNumber: data['phoneNumber'] as String?,
  role: data['role']?.toString() ?? 'User',
  emailConfirmed: data['emailConfirmed'] as bool? ?? false,
);
```

### Step 7.4: Commit

```bash
git add mobile/lib/features/orders/ mobile/lib/features/profile/
git commit -m "feat: implement orders full lifecycle + fix profile entity"
```

---

## Thong tin bo sung

### Check lai ApiEndpoints

File `mobile/lib/core/constants/api_endpoints.dart` da dinh nghia dung cac endpoint. Dam bao cac repository su dung `ApiEndpoints.*` thay vi hardcode string.

### Check ApiClient baseUrl

`AppConstants.apiBaseUrl` tra ve `http://localhost:5000/api` (web) hoac `http://10.0.2.2:5000/api` (android). Dam bao backend chay dung port 5000.

### Token Refresh Loop Fix

Trong `api_client.dart`, interceptor refresh da skip cac auth endpoints. Tuy nhien can them `/auth/refresh` vao danh sach skip:

```dart
if (path.contains('/auth/login') ||
    path.contains('/auth/refresh') ||  // <-- Da co
    path.contains('/auth/register')) {
```

Da OK trong code hien tai.

---

## Uu tien thuc hien

1. **Task 1: Sign Up** -- Nghiem trong nhat, bug parsing mat token
2. **Task 2: Wallet** -- Feature quan trong, 100% mock
3. **Task 3: Food Order** -- Feature quan trong, 100% mock
4. **Task 4: Delivery** -- Feature moi, 100% mock
5. **Task 5: Send/Receive** -- Feature moi, 100% mock
6. **Task 6: Locker** -- Fix endpoint consistency
7. **Task 7: Orders** -- Full lifecycle
