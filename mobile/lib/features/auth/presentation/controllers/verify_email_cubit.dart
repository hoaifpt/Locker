import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/usecases/resend_verification_email_usecase.dart';
import 'verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  final ResendVerificationEmailUseCase _resendVerificationEmailUseCase;

  VerifyEmailCubit(
      {required ResendVerificationEmailUseCase resendVerificationEmailUseCase})
      : _resendVerificationEmailUseCase = resendVerificationEmailUseCase,
        super(const VerifyEmailState());

  Future<void> resendEmail(String? email) async {
    if (email == null || email.isEmpty) {
      emit(state.copyWith(errorMessage: 'Không tìm thấy địa chỉ email.'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      await _resendVerificationEmailUseCase(email);
      emit(state.copyWith(
        isLoading: false,
        successMessage:
            'Đã gửi lại email xác thực. Vui lòng kiểm tra hộp thư của bạn.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Đã xảy ra lỗi không mong muốn.'));
    }
  }
}
