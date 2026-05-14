import '../entities/profile_info.dart';
import '../repositories/i_profile_repository.dart';

class GetProfileUsecase {
  final IProfileRepository repository;

  GetProfileUsecase({required this.repository});

  Future<ProfileInfo> call() => repository.getProfile();
}
