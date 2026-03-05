/// Abstract contract - data layer phải implement
abstract class IAuthRepository {
  Future<bool> login(String username, String password);
  Future<void> logout({bool callServer});
  Future<bool> checkLoginStatus();
  Future<void> refreshToken();
}
