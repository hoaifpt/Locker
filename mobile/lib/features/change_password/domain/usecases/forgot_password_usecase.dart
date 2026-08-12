import '../repositories/i_change_password_repository.dart';

class ForgotPasswordUseCase {
  final IChangePasswordRepository _repository;

  ForgotPasswordUseCase({required IChangePasswordRepository repository})
      : _repository = repository;

  Future<void> call({required String email}) async {
    return _repository.forgotPassword(email: email);
  }
}
