import 'package:locker_mobile/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:locker_mobile/features/home/domain/entities/user.dart';

class SignInWithGoogleUsecase {
  final IAuthRepository repository;

  SignInWithGoogleUsecase(this.repository);

  Future<User> call() {
    return repository.signInWithGoogle();
  }
}