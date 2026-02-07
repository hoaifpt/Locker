import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  static const String _tokenKey = 'auth_token';

  // Đăng nhập
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.client.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        // Giả sử API trả về json: { "token": "abc...", ... }
        final token = data['token'];

        if (token != null) {
          await _saveToken(token);
          return true;
        }
      }
      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Sai tài khoản hoặc mật khẩu');
        }
      }
      throw Exception('Lỗi đăng nhập: ${e.toString()}');
    }
  }

  // Lưu token vào máy & Cập nhật cho ApiClient dùng luôn
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _apiClient.setToken(token);
  }

  // Kiểm tra xem đã đăng nhập chưa (dùng khi mở áp)
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      _apiClient.setToken(token);
      return true;
    }
    return false;
  }

  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _apiClient.clearToken();
  }
}
