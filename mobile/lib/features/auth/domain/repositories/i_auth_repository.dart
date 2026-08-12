import '../../../home/domain/entities/user.dart';

abstract class IAuthRepository {
  Future<User> signInWithGoogle();
  Future<bool> login(String username, String password);
  Future<void> refreshToken();
  Future<void> loginWithToken(String token, String refreshToken);
  Future<bool> checkLoginStatus();
  Future<void> logout({bool callServer = false});
  Future<void> resendVerificationEmail(String email);
}
