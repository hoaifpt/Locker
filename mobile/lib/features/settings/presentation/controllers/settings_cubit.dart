import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_preferences_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/logout_settings_usecase.dart';
import '../../domain/usecases/update_preferences_usecase.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetProfileUsecase _getProfile;
  final GetPreferencesUsecase _getPreferences;
  final UpdatePreferencesUsecase _updatePreferences;
  final LogoutSettingsUsecase _logout;

  SettingsCubit({
    required GetProfileUsecase getProfile,
    required GetPreferencesUsecase getPreferences,
    required UpdatePreferencesUsecase updatePreferences,
    required LogoutSettingsUsecase logout,
  })  : _getProfile = getProfile,
        _getPreferences = getPreferences,
        _updatePreferences = updatePreferences,
        _logout = logout,
        super(const SettingsInitial());

  Future<void> load() async {
    emit(const SettingsLoading());
    try {
      final profile = await _getProfile();
      final prefs = await _getPreferences();
      emit(SettingsLoaded(
        profile: profile,
        pushNotifications: prefs['pushNotifications'] ?? true,
        darkMode: prefs['darkMode'] ?? false,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> togglePushNotifications(bool value) async {
    final current = state;
    if (current is! SettingsLoaded) return;
    final updated = current.copyWith(pushNotifications: value);
    emit(updated);
    await _updatePreferences({'pushNotifications': value});
  }

  Future<void> toggleDarkMode(bool value) async {
    final current = state;
    if (current is! SettingsLoaded) return;
    final updated = current.copyWith(darkMode: value);
    emit(updated);
    await _updatePreferences({'darkMode': value});
  }

  Future<void> logout() async {
    await _logout();
    emit(const SettingsLoggedOut());
  }
}
