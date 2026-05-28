/// API Endpoints constants for Flutter mobile app
/// Easy integration with HTTP client libraries
library;

class ApiEndpoints {
  static const String apiBase = '';

  // Auth endpoints
  static const String login = '$apiBase/auth/login';
  static const String register = '$apiBase/auth/register';
  static const String verifyEmail = '$apiBase/auth/verify-email';
  static const String resendVerification = '$apiBase/auth/resend-verification';
  static const String refresh = '$apiBase/auth/refresh';
  static const String logout = '$apiBase/auth/logout';
  static const String logoutAll = '$apiBase/auth/logout-all';
  static const String forgotPassword = '$apiBase/auth/forgot-password';
  static const String resetPassword = '$apiBase/auth/reset-password';

  // Users endpoints
  static const String getMe = '$apiBase/users/me';
  static const String updateMe = '$apiBase/users/me';
  static const String changePassword = '$apiBase/users/me/change-password';

  // Lockers endpoints
  static const String lockersGetAll = '$apiBase/lockers';
  static const String lockersCreate = '$apiBase/lockers';
  static const String lockersGetAvailable = '$apiBase/lockers/available';
  static const String lockersQrScan = '$apiBase/lockers/qr-scan';
  static const String lockersScanHistory = '$apiBase/lockers/scan-history';

  static String lockersGetById(String id) => '$apiBase/lockers/$id';
  static String lockersUpdate(String id) => '$apiBase/lockers/$id';
  static String lockersDelete(String id) => '$apiBase/lockers/$id';
  static String lockersUpdateSlotStatus(String id, int slotIndex) =>
      '$apiBase/lockers/$id/slots/$slotIndex/status';

  // Bookings endpoints
  static const String bookingsGetMy = '$apiBase/bookings/my';
  static const String bookingsCreate = '$apiBase/bookings';

  static String bookingsGetById(String id) => '$apiBase/bookings/$id';
  static String bookingsSetPin(String id) => '$apiBase/bookings/$id/set-pin';
  static String bookingsVerifyPin(String id) =>
      '$apiBase/bookings/$id/verify-pin';
  static String bookingsComplete(String id) => '$apiBase/bookings/$id/complete';
  static String bookingsCancel(String id) => '$apiBase/bookings/$id/cancel';

  // Orders endpoints
  static const String ordersGetMy = '$apiBase/orders/my';
  static const String ordersCreate = '$apiBase/orders';

  static String ordersGetById(String id) => '$apiBase/orders/$id';
  static String ordersConfirm(String id) => '$apiBase/orders/$id/confirm';
  static String ordersActivate(String id) => '$apiBase/orders/$id/activate';
  static String ordersComplete(String id) => '$apiBase/orders/$id/complete';
  static String ordersCancel(String id) => '$apiBase/orders/$id/cancel';
  static String ordersExtend(String id) => '$apiBase/orders/$id/extend';
  static String ordersSetPin(String id) => '$apiBase/orders/$id/set-pin';
  static String ordersPaymentLink(String id) =>
      '$apiBase/orders/$id/payment-link';

  // Packages endpoints
  static const String packagesGetAll = '$apiBase/packages';
  static const String packagesCreate = '$apiBase/packages';

  static String packagesGetById(String id) => '$apiBase/packages/$id';
  static String packagesUpdate(String id) => '$apiBase/packages/$id';
  static String packagesDelete(String id) => '$apiBase/packages/$id';

  // Payments endpoints
  static const String paymentsGetMy = '$apiBase/payments/my';
  static const String paymentsCreate = '$apiBase/payments';

  static String paymentsGetById(String id) => '$apiBase/payments/$id';
  static String paymentsGetByBookingId(String bookingId) =>
      '$apiBase/payments/booking/$bookingId';
  static String paymentsComplete(String id) => '$apiBase/payments/$id/complete';

  // Admin endpoints
  static const String adminUsersGetAll = '$apiBase/admin/users';
  static const String adminBookingsGetAll = '$apiBase/admin/bookings';
  static const String adminPaymentsGetAll = '$apiBase/admin/payments';

  static String adminUsersUpdateRole(String id) =>
      '$apiBase/admin/users/$id/role';
  static String adminUsersDeactivate(String id) =>
      '$apiBase/admin/users/$id/deactivate';
  static String adminUsersActivate(String id) =>
      '$apiBase/admin/users/$id/activate';

  // Health endpoint
  static const String healthCheck = '$apiBase/health';

  // Notifications endpoints
  static const String notificationsGetMy = '$apiBase/notifications/my';
  static String notificationsMarkAsRead(String id) =>
      '$apiBase/notifications/$id/mark-as-read';
  static const String notificationsMarkAllAsRead =
      '$apiBase/notifications/mark-all-as-read';

  /// Build URL with query parameters
  /// Example: buildUrl(ApiEndpoints.bookingsGetMy, {'status': 'Active'})
  static String buildUrl(String endpoint, [Map<String, dynamic>? queryParams]) {
    if (queryParams == null || queryParams.isEmpty) {
      return endpoint;
    }

    final queryString = queryParams.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    return '$endpoint?$queryString';
  }
}

// Usage examples:
//
// GET request without parameters:
// var response = await client.get(Uri.parse(ApiEndpoints.getMe));
//
// GET request with dynamic ID:
// var response = await client.get(Uri.parse(ApiEndpoints.lockersGetById('locker-123')));
//
// GET request with query parameters:
// var url = ApiEndpoints.buildUrl(ApiEndpoints.bookingsGetMy, {'status': 'Active'});
// var response = await client.get(Uri.parse(url));
//
// POST request:
// var response = await client.post(
//   Uri.parse(ApiEndpoints.login),
//   headers: {'Content-Type': 'application/json'},
//   body: jsonEncode({'email': 'user@example.com', 'password': 'pass123'})
// );
