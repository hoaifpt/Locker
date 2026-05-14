import '../entities/profile_info.dart';

abstract class IProfileRepository {
  Future<ProfileInfo> getProfile();
}
