import '../repositories/i_settings_repository.dart';

class UpdatePreferencesUsecase {
  final ISettingsRepository _repo;
  UpdatePreferencesUsecase(this._repo);

  Future<void> call(Map<String, bool> prefs) => _repo.updatePreferences(prefs);
}
