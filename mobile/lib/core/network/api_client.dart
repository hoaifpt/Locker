import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => logInfo(obj.toString()),
    ));

    // Refresh token interceptor: tự gia hạn token khi API trả 401
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          try {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Retry request gốc với token mới
              final opts = e.requestOptions;
              opts.headers['Authorization'] =
                  _dio.options.headers['Authorization'];
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            }
          } catch (_) {
            logWarn('Refresh token thất bại, chuyển về đăng nhập');
          }
        }
        handler.next(e);
      },
    ));
  }

  Future<bool> _tryRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('auth_refresh_token');
    if (refresh == null) return false;

    final res =
        await _dio.post('/auth/refresh', data: {'refreshToken': refresh});
    if (res.statusCode == 200) {
      final access = res.data['token'] as String?;
      final newRefresh = res.data['refreshToken'] as String? ?? refresh;
      if (access != null) {
        await prefs.setString('auth_access_token', access);
        await prefs.setString('auth_refresh_token', newRefresh);
        setToken(access);
        return true;
      }
    }
    return false;
  }

  Dio get client => _dio;

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }
}
