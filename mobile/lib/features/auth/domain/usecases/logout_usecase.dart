import '../repositories/i_auth_repository.dart';

class LogoutUsecase {
  final IAuthRepository _repo;
  LogoutUsecase(this._repo);

  Future<void> call({bool callServer = true}) {
    return _repo.logout(callServer: callServer);
  }
}
