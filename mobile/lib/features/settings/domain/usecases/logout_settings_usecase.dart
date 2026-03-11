import '../repositories/i_settings_repository.dart';

class LogoutSettingsUsecase {
  final ISettingsRepository _repo;
  LogoutSettingsUsecase(this._repo);

  Future<void> call() => _repo.logout();
}
