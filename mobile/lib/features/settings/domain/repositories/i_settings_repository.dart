import '../entities/user_profile.dart';

abstract class ISettingsRepository {
  Future<UserProfile> getProfile();
  Future<Map<String, bool>> getPreferences();
  Future<void> updatePreferences(Map<String, bool> prefs);
  Future<void> logout();
}
