import '../repositories/i_settings_repository.dart';

class UpdatePreferencesUsecase {
  final ISettingsRepository _repo;
  UpdatePreferencesUsecase(this._repo);

  Future<void> call(Map<String, dynamic> prefs) =>
      _repo.updatePreferences(prefs);
}