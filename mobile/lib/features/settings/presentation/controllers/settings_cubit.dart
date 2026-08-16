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
        darkMode: prefs['darkMode'] as bool? ?? false,
        fontSize: FontSize.fromString(prefs['fontSize'] as String?),
        notifications: NotificationPrefs(
          sound: prefs['notificationsSound'] as bool? ?? true,
          vibration: prefs['notificationsVibration'] as bool? ?? true,
          orderUpdates: prefs['notificationsOrderUpdates'] as bool? ?? true,
          deliveryUpdates:
              prefs['notificationsDeliveryUpdates'] as bool? ?? true,
          promotions: prefs['notificationsPromotions'] as bool? ?? false,
        ),
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    final current = state;
    if (current is! SettingsLoaded) return;
    emit(current.copyWith(darkMode: value));
    await _updatePreferences({'darkMode': value});
  }

  Future<void> setFontSize(FontSize value) async {
    final current = state;
    if (current is! SettingsLoaded) return;
    emit(current.copyWith(fontSize: value));
    await _updatePreferences({
      'fontSize': value == FontSize.easyRead ? 'easy-read' : 'normal',
    });
  }

  /// Persists a partial notification toggle change. Called by the
  /// notification card whenever a switch flips. Persists the changed
  /// flag only (the rest of the prefs stay as-is on the backend).
  Future<void> updateNotifications(Map<String, bool> changes) async {
    final current = state;
    if (current is! SettingsLoaded) return;
    final updated = current.notifications.copyWith(
      sound: changes['sound'],
      vibration: changes['vibration'],
      orderUpdates: changes['orderUpdates'],
      deliveryUpdates: changes['deliveryUpdates'],
      promotions: changes['promotions'],
    );
    emit(current.copyWith(notifications: updated));
    // The backend stores these as a flat map; we re-emit the full
    // picture so a single toggle doesn't blow away the others.
    await _updatePreferences({
      'notificationsSound': updated.sound,
      'notificationsVibration': updated.vibration,
      'notificationsOrderUpdates': updated.orderUpdates,
      'notificationsDeliveryUpdates': updated.deliveryUpdates,
      'notificationsPromotions': updated.promotions,
    });
  }

  Future<void> logout() async {
    await _logout();
    emit(const SettingsLoggedOut());
  }
}