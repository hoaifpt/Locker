import '../repositories/i_auth_repository.dart';

class CheckLoginUsecase {
  final IAuthRepository _repo;
  CheckLoginUsecase(this._repo);

  Future<bool> call() {
    return _repo.checkLoginStatus();
  }
}
