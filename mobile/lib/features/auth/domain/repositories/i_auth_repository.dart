abstract class IAuthRepository {
  Future<bool> login(String username, String password);
  Future<void> logout({bool callServer = true});
  Future<bool> checkLoginStatus();
  Future<void> resendVerificationEmail(String email);
}
