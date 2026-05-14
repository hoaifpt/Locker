import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  late final Dio _refreshDio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    final baseOptions = BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      // Increase receive timeout to 60s to avoid transient receive timeouts
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(baseOptions);
    _refreshDio = Dio(baseOptions);

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => logInfo(obj.toString()),
    ));

    // Timing interceptor: measure elapsed time for each request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['requestStartTime'] = DateTime.now();
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final start =
            response.requestOptions.extra['requestStartTime'] as DateTime?;
        if (start != null) {
          final elapsed = DateTime.now().difference(start).inMilliseconds;
          logInfo(
              '[API] ${response.requestOptions.method} ${response.requestOptions.path} -> ${response.statusCode} (${elapsed}ms)');
        }
        return handler.next(response);
      },
      onError: (err, handler) {
        final start = err.requestOptions.extra['requestStartTime'] as DateTime?;
        if (start != null) {
          final elapsed = DateTime.now().difference(start).inMilliseconds;
          logWarn(
              '[API] ${err.requestOptions.method} ${err.requestOptions.path} -> ERROR (${elapsed}ms): ${err.message}');
        }
        return handler.next(err);
      },
    ));

    // Refresh token interceptor: tự gia hạn token khi API trả 401
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (e, handler) async {
        final path = e.requestOptions.path;
        if (path.contains('/auth/login') ||
            path.contains('/auth/refresh') ||
            path.contains('/auth/register')) {
          return handler.next(e);
        }

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
    final refresh = prefs.getString(AppConstants.refreshTokenKey);
    if (refresh == null) return false;

    try {
      final res = await _refreshDio
          .post('/auth/refresh', data: {'refreshToken': refresh});
      if (res.statusCode == 200) {
        final access = res.data['token'] as String?;
        final newRefresh = res.data['refreshToken'] as String? ?? refresh;
        if (access != null) {
          await prefs.setString(AppConstants.accessTokenKey, access);
          await prefs.setString(AppConstants.refreshTokenKey, newRefresh);
          setToken(access);
          return true;
        }
      }
    } catch (_) {
      await prefs.remove(AppConstants.accessTokenKey);
      await prefs.remove(AppConstants.refreshTokenKey);
      clearToken();
      return false;
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
