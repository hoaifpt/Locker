import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/repositories/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient = ApiClient();

  /// Đăng nhập với identifier/password theo API backend (`/api/auth/login`)
  @override
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.authLogin,
        data: {'identifier': username, 'password': password},
      );

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

  /// Đăng nhập với Google thông qua Firebase, sau đó trao đổi token với backend
  @override
  Future<bool> signInWithGoogle() async {
    try {
      // 1. Bắt đầu quy trình đăng nhập Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Người dùng có thể hủy quy trình đăng nhập
      if (googleUser == null) {
        return false;
      }

      // 2. Lấy thông tin xác thực từ tài khoản Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Tạo credential cho Firebase từ token của Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase với credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AppException('Đăng nhập Firebase thất bại, không có người dùng.');
      }

      // 5. Lấy Firebase ID token để gửi về backend của bạn
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        throw AppException('Không thể lấy Firebase ID token.');
      }

      // 6. Gửi token đến backend để xác thực và nhận về JWT của hệ thống
      final response = await _apiClient.client.post(
        ApiEndpoints.authGoogleLogin, // Endpoint này cần được tạo ở backend
        data: {'idToken': idToken},
      );

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
    } on FirebaseAuthException catch (e) {
      throw AppException('Lỗi xác thực Firebase: ${e.message}');
    } catch (e) {
      // Đảm bảo đăng xuất khỏi Google nếu có lỗi xảy ra ở các bước sau
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      throw AppException('Lỗi đăng nhập Google: $e');
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

    final response = await _apiClient.client.post(
      ApiEndpoints.authRefresh,
      data: {'refreshToken': refresh},
    );

    final data = response.data;
    final access = data['token'] as String?;
    final newRefresh = data['refreshToken'] as String? ?? refresh;
    if (access == null) {
      throw UnauthorizedException('Refresh token không hợp lệ');
    }
    await _saveTokens(access, newRefresh);
  }

  /// Dùng sau khi register thành công, tự động đăng nhập
  @override
  Future<void> loginWithToken(String token, String refreshToken) async =>
      await _saveTokens(token, refreshToken);

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
        await _apiClient.client.post(
          ApiEndpoints.authLogout,
          data: {'refreshToken': refresh},
        );
      } catch (_) {
        // Bỏ qua lỗi logout server để vẫn xóa token local
      }
    }

    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    _apiClient.clearToken();
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    try {
      // Giả định endpoint là /auth/resend-verification-email
      await _apiClient.client.post(
        '/auth/resend-verification-email',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi gửi lại email xác thực.');
    } catch (e) {
      throw AppException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }
}
