import '../entities/user.dart';
import '../repositories/i_user_repository.dart';

class GetUserProfile {
  final IUserRepository _repo;
  GetUserProfile(this._repo);

  Future<User> call() => _repo.getProfile();
}
