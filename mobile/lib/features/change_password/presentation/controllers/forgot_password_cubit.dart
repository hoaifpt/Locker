import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  ForgotPasswordCubit({
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _forgotPasswordUseCase = forgotPasswordUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        super(ForgotPasswordState.initial());

  Future<void> sendOtp({required String email}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _forgotPasswordUseCase(email: email);
      emit(state.copyWith(isLoading: false, isOtpSent: true, email: email));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> resetPassword({
    required String otp,
    required String newPassword,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _resetPasswordUseCase(
        email: state.email ?? '',
        otp: otp,
        newPassword: newPassword,
      );
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void resetState() {
    emit(ForgotPasswordState.initial());
  }
}
