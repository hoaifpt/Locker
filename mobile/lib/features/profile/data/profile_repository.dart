import '../../profile/domain/entities/profile_info.dart';
import '../../profile/domain/repositories/i_profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  @override
  Future<ProfileInfo> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const ProfileInfo(
      id: 'user_1001',
      fullName: 'Minh Nguyen',
      email: 'minh.nguyen@example.com',
      phone: '+84912345678',
      points: 1250,
    );
  }
}
