import '../../../../core/exceptions/app_exception.dart';
import '../repositories/i_auth_repository.dart';

class ResendVerificationEmailUseCase {
  final IAuthRepository _repository;
  static final _emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  ResendVerificationEmailUseCase(this._repository);

  Future<void> call(String email) async {
    if (!_emailRegExp.hasMatch(email)) {
      throw ValidationException(
        'Email không hợp lệ.',
        fieldErrors: {
          'email': ['Vui lòng nhập một địa chỉ email hợp lệ.']
        },
      );
    }
    await _repository.resendVerificationEmail(email);
  }
}
