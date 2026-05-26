import '../repositories/i_profile_repository.dart';

class LogoutUsecase {
  final IProfileRepository repository;

  LogoutUsecase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}
