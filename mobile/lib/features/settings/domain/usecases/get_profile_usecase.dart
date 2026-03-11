import '../entities/user_profile.dart';
import '../repositories/i_settings_repository.dart';

class GetProfileUsecase {
  final ISettingsRepository _repo;
  GetProfileUsecase(this._repo);

  Future<UserProfile> call() => _repo.getProfile();
}
