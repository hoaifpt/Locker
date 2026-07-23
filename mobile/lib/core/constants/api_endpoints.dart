/// API Endpoints constants for Flutter mobile app
/// Easy integration with HTTP client libraries
library;

class ApiEndpoints {
  // Auth
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';

  // User
  static const String userMe = '/users/me';
  static const String userChangePassword = '/users/me/change-password';

  // Lockers
  static const String lockers = '/lockers';
  static const String lockersAvailable = '/lockers/available';
  static const String lockersMap = '/lockers/map';
  static const String lockersQrScan = '/lockers/qr-scan';
  static const String lockersScanHistory = '/lockers/scan-history';
  static String lockerById(String id) => '/lockers/$id';
  static String lockerOpen(String id) => '/lockers/$id/open';

  // Orders
  static const String ordersReserve = '/orders/reserve';
  static const String ordersMy = '/orders/my';
  static const String ordersAvailabilitySlots = '/orders/availability/slots';
  static String orderById(String id) => '/orders/$id';
  static String orderConfirm(String id) => '/orders/$id/confirm';
  static String orderActivate(String id) => '/orders/$id/activate';
  static String orderComplete(String id) => '/orders/$id/complete';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderExtend(String id) => '/orders/$id/extend';

  // Payments
  static const String payments = '/payments';
  static String paymentById(String id) => '/payments/$id';
  static String paymentByBookingId(String bookingId) =>
      '/payments/booking/$bookingId';

  // Restaurants
  static const String restaurants = '/restaurants';
  static String restaurantById(String id) => '/restaurants/$id';
  static String restaurantMenu(String id) => '/restaurants/$id/menu';

  // Food Orders
  static const String foodOrders = '/food-orders';
  static const String foodOrdersMy = '/food-orders/my';
  static String foodOrderById(String id) => '/food-orders/$id';

  // Delivery
  static const String deliveryPackageSizes = '/delivery/package-sizes';
  static const String deliveryRequests = '/delivery/requests';
  static const String deliveryRequestsMy = '/delivery/requests/my';
  static String deliveryTrack(String trackingCode) =>
      '/delivery/requests/track/$trackingCode';
  static String deliverySubmitReceiveCode(String lockerId, int slotIndex) =>
      '/delivery/requests/submit-receive/$lockerId/$slotIndex';

  // Send/Receive
  static const String sendReceiveOrders = '/send-receive/orders';
  static const String sendReceiveOrdersMy = '/send-receive/orders/my';
  static String sendReceiveOrderById(String id) => '/send-receive/orders/$id';
  static String sendReceiveOrderConfirm(String id) =>
      '/send-receive/orders/$id/confirm';
  static String sendReceiveOrderComplete(String id) =>
      '/send-receive/orders/$id/complete';

  // Wallet
  static const String walletOverview = '/wallet/overview';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletBalance = '/wallet/balance';
  static const String walletTopUp = '/wallet/top-up';
  static const String walletTransfer = '/wallet/transfer';
  static const String walletTopUpVnPayInit = '/wallet/top-up/vnpay/init';
  static String walletTopUpVnPayReturn() => '/wallet/top-up/vnpay/return';

  // Notifications
  static const String notificationsMy = '/notifications/my';
  static String notificationMarkAsRead(String id) =>
      '/notifications/$id/mark-as-read';
  static const String notificationsMarkAllAsRead =
      '/notifications/mark-all-as-read';

  // Packages
  static const String packages = '/packages';
  static String packageById(String id) => '/packages/$id';
  // Endpoint for exchanging a Firebase ID token for a custom backend JWT
  static const String authGoogleLogin = '/auth/google-login';
}
