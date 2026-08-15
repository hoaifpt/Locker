import '../entities/user_profile.dart';

abstract class ISettingsRepository {
  Future<UserProfile> getProfile();
  Future<Map<String, dynamic>> getPreferences();
  Future<void> updatePreferences(Map<String, dynamic> prefs);
  Future<void> logout();
}
