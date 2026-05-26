import '../entities/personal_info_overview.dart';

abstract class IPersonalInfoRepository {
  Future<PersonalInfoOverview> getOverview();
}