import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/i_settings_repository.dart';
import 'models/user_profile_model.dart';

class SettingsRepository implements ISettingsRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiClient.client.get('/users/me');
      return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return UserProfileModel.empty();
    }
  }

  @override
  Future<Map<String, bool>> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'pushNotifications':
          prefs.getBool(AppConstants.prefsPushNotificationsKey) ?? true,
      'darkMode': prefs.getBool(AppConstants.prefsDarkModeKey) ?? false,
    };
  }

  @override
  Future<void> updatePreferences(Map<String, bool> prefsMap) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefsMap.containsKey('pushNotifications')) {
      await prefs.setBool(AppConstants.prefsPushNotificationsKey,
          prefsMap['pushNotifications']!);
    }
    if (prefsMap.containsKey('darkMode')) {
      await prefs.setBool(AppConstants.prefsDarkModeKey, prefsMap['darkMode']!);
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(AppConstants.refreshTokenKey);
    if (refresh != null) {
      try {
        await _apiClient.client
            .post('/auth/logout', data: {'refreshToken': refresh});
      } catch (_) {}
    }
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    _apiClient.clearToken();
  }
}
