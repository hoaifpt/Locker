import '../entities/user_profile.dart';
import '../repositories/i_profile_repository.dart';

class GetProfileUsecase {
  final IProfileRepository repository;

  GetProfileUsecase({required this.repository});

  Future<UserProfile> call() => repository.getUserProfile();
}
