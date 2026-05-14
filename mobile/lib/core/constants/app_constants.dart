import 'package:flutter/foundation.dart';

class AppConstants {
  // Base URL cho API
  // Android Emulator: 10.0.2.2
  // Web hoặc Windows App: localhost
  // Thiết bị thật: Dùng IP LAN (VD: 192.168.1.x)
  static String get apiBaseUrl =>
      kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';

  static const String appName = 'Smart Locker';

  // SharedPreferences keys — dùng chung toàn app
  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';
  static const String prefsPushNotificationsKey = 'pref_push_notifications';
  static const String prefsDarkModeKey = 'pref_dark_mode';
}
