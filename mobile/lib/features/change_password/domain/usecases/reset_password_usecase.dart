import '../repositories/i_change_password_repository.dart';

class ResetPasswordUseCase {
  final IChangePasswordRepository _repository;

  ResetPasswordUseCase({required IChangePasswordRepository repository})
      : _repository = repository;

  Future<void> call({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return _repository.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
