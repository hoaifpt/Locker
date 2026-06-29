import '../repositories/i_change_password_repository.dart';

class ChangePasswordUseCase {
  final IChangePasswordRepository _repository;

  ChangePasswordUseCase({required IChangePasswordRepository repository})
    : _repository = repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
