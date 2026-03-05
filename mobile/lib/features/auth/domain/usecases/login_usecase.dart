import '../repositories/i_auth_repository.dart';

class LoginUsecase {
  final IAuthRepository _repo;
  LoginUsecase(this._repo);

  /// Trả về true nếu đăng nhập thành công
  Future<bool> call(String username, String password) {
    return _repo.login(username, password);
  }
}
