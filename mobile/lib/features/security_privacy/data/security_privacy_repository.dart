import '../domain/entities/security_privacy_overview.dart';
import '../domain/repositories/i_security_privacy_repository.dart';
import 'models/security_privacy_overview_model.dart';

class SecurityPrivacyRepository implements ISecurityPrivacyRepository {
  @override
  Future<SecurityPrivacyOverview> getOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    return SecurityPrivacyOverviewModel.fromJson({
      'faceIdEnabled': true,
      'twoFactorEnabled': false,
      'loginAlertEnabled': true,
    });
  }
}
