import 'environment.dart';

class AppConstants {
  AppConstants._();

  static String get apiBaseUrl => Environment.apiBaseUrl;

  static const String appName = 'Smart Locker';

  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';

  static const String prefsPushNotificationsKey =
      'pref_push_notifications';

  static const String prefsDarkModeKey =
      'pref_dark_mode';
}