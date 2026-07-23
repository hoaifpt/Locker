import '../repositories/i_auth_repository.dart';

class SignInWithGoogleUsecase {
  final IAuthRepository _repo;
  SignInWithGoogleUsecase(this._repo);

  /// Trả về true nếu đăng nhập thành công
  Future<bool> call() => _repo.signInWithGoogle();
}
