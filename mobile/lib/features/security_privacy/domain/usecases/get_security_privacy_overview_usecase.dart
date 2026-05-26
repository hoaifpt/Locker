import '../entities/security_privacy_overview.dart';
import '../repositories/i_security_privacy_repository.dart';

class GetSecurityPrivacyOverviewUseCase {
  final ISecurityPrivacyRepository repository;

  GetSecurityPrivacyOverviewUseCase({required this.repository});

  Future<SecurityPrivacyOverview> call() {
    return repository.getOverview();
  }
}
