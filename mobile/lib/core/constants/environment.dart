import 'package:flutter/foundation.dart';

class Environment {
  Environment._();

  static const String _api = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get apiBaseUrl {
    // Nếu truyền --dart-define thì dùng
    if (_api.isNotEmpty) {
      return _api;
    }

    // Local
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    // Android Emulator
    return 'http://10.0.2.2:5000/api';
  }
}