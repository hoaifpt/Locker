import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/repositories/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient = ApiClient();

  /// Đăng nhập với identifier/password theo API backend (`/api/auth/login`)
  @override
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.client.post('/auth/login', data: {
        'identifier': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final access = data['token'] as String?;
        final refresh = data['refreshToken'] as String?;

        if (access != null && refresh != null) {
          await _saveTokens(access, refresh);
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Sai tài khoản hoặc mật khẩu');
      }
      throw NetworkException(e.message ?? 'Lỗi mạng');
    } catch (e) {
      throw AppException('Lỗi đăng nhập: $e');
    }
  }

  /// Refresh token nếu cần (backend: /api/auth/refresh)
  @override
  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(AppConstants.refreshTokenKey);
    if (refresh == null) {
      throw UnauthorizedException('Thiếu refresh token');
    }

    final response = await _apiClient.client.post('/auth/refresh', data: {
      'refreshToken': refresh,
    });

    final data = response.data;
    final access = data['token'] as String?;
    final newRefresh = data['refreshToken'] as String? ?? refresh;
    if (access == null) {
      throw UnauthorizedException('Refresh token không hợp lệ');
    }
    await _saveTokens(access, newRefresh);
  }

  /// Lưu token vào máy & Cập nhật cho ApiClient dùng luôn
  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, access);
    await prefs.setString(AppConstants.refreshTokenKey, refresh);
    _apiClient.setToken(access);
  }

  /// Kiểm tra xem đã đăng nhập chưa (dùng khi mở app)
  @override
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.accessTokenKey);
    if (token != null && token.isNotEmpty) {
      _apiClient.setToken(token);
      return true;
    }
    return false;
  }

  /// Đăng xuất (xóa token cục bộ). Nếu muốn gọi API logout, thêm gọi /auth/logout.
  @override
  Future<void> logout({bool callServer = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(AppConstants.refreshTokenKey);

    if (callServer && refresh != null) {
      try {
        await _apiClient.client.post('/auth/logout', data: {
          'refreshToken': refresh,
        });
      } catch (_) {
        // Bỏ qua lỗi logout server để vẫn xóa token local
      }
    }

    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    _apiClient.clearToken();
  }
}
