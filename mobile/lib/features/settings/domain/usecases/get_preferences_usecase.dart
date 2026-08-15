import '../repositories/i_settings_repository.dart';

class GetPreferencesUsecase {
  final ISettingsRepository _repo;
  const GetPreferencesUsecase(this._repo);

  Future<Map<String, dynamic>> call() => _repo.getPreferences();
}