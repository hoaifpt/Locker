import '../entities/user_profile.dart';

abstract class IProfileRepository {
  Future<UserProfile> getUserProfile();
  Future<void> logout();
}
