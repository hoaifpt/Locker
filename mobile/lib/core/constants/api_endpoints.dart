/// API Endpoints constants for Flutter mobile app
/// Easy integration with HTTP client libraries
library;

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
  static const String lockersQrScan = '$apiBase/lockers/qr-scan';
  static const String lockersScanHistory = '$apiBase/lockers/scan-history';
  static String lockerById(String id) => '$apiBase/lockers/$id';
  static String lockerOpen(String id) => '$apiBase/lockers/$id/open';

  // Orders
  static const String ordersReserve = '$apiBase/orders/reserve';
  static const String ordersMy = '$apiBase/orders/my';
  static const String ordersAvailabilitySlots =
      '$apiBase/orders/availability/slots';
  static String orderById(String id) => '$apiBase/orders/$id';
  static String orderConfirm(String id) => '$apiBase/orders/$id/confirm';
  static String orderActivate(String id) => '$apiBase/orders/$id/activate';
  static String orderComplete(String id) => '$apiBase/orders/$id/complete';
  static String orderCancel(String id) => '$apiBase/orders/$id/cancel';
  static String orderExtend(String id) => '$apiBase/orders/$id/extend';

  // Payments
  static const String payments = '$apiBase/payments';
  static String paymentById(String id) => '$apiBase/payments/$id';
  static String paymentByBookingId(String bookingId) =>
      '$apiBase/payments/booking/$bookingId';

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
  static String deliveryTrack(String trackingCode) =>
      '$apiBase/delivery/requests/track/$trackingCode';

  // Send/Receive
  static const String sendReceiveOrders = '$apiBase/send-receive/orders';
  static const String sendReceiveOrdersMy = '$apiBase/send-receive/orders/my';
  static String sendReceiveOrderById(String id) =>
      '$apiBase/send-receive/orders/$id';
  static String sendReceiveOrderConfirm(String id) =>
      '$apiBase/send-receive/orders/$id/confirm';
  static String sendReceiveOrderComplete(String id) =>
      '$apiBase/send-receive/orders/$id/complete';

  // Wallet
  static const String walletOverview = '$apiBase/wallet/overview';
  static const String walletTransactions = '$apiBase/wallet/transactions';
  static const String walletBalance = '$apiBase/wallet/balance';
  static const String walletTopUp = '$apiBase/wallet/top-up';
  static const String walletTransfer = '$apiBase/wallet/transfer';
  static const String walletTopUpVnPayInit =
      '$apiBase/wallet/top-up/vnpay/init';
  static String walletTopUpVnPayReturn() =>
      '$apiBase/wallet/top-up/vnpay/return';

  // Notifications
  static const String notificationsMy = '$apiBase/notifications/my';
  static String notificationMarkAsRead(String id) =>
      '$apiBase/notifications/$id/mark-as-read';
  static const String notificationsMarkAllAsRead =
      '$apiBase/notifications/mark-all-as-read';

  // Packages
  static const String packages = '$apiBase/packages';
  static String packageById(String id) => '$apiBase/packages/$id';
}
