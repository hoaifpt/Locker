import '../entities/personal_info_overview.dart';
import '../repositories/i_personal_info_repository.dart';

class GetPersonalInfoOverviewUseCase {
  final IPersonalInfoRepository repository;

  const GetPersonalInfoOverviewUseCase({required this.repository});

  Future<PersonalInfoOverview> call() => repository.getOverview();
}