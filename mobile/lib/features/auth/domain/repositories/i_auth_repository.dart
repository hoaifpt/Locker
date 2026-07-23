abstract class IAuthRepository {
  Future<bool> login(String username, String password);
  Future<bool> signInWithGoogle();
  Future<void> refreshToken();
  Future<void> loginWithToken(String token, String refreshToken);
  Future<bool> checkLoginStatus();
  Future<void> logout({bool callServer = false});
  Future<void> resendVerificationEmail(String email);
}
