import '../entities/personal_info_overview.dart';

abstract class IPersonalInfoRepository {
  Future<PersonalInfoOverview> getOverview();
  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  });
}
