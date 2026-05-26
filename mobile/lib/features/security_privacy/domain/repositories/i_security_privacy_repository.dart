import '../entities/security_privacy_overview.dart';

abstract class ISecurityPrivacyRepository {
  Future<SecurityPrivacyOverview> getOverview();
}
