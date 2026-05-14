import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sign_up_request.dart' show SignUpRequest;
import '../../domain/usecases/sign_up_usecase.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final SignUpUseCase signUpUseCase;

  SignUpCubit({required this.signUpUseCase}) : super(SignUpState());

  void setFullName(String name) {
    emit(state.copyWith(fullName: name));
  }

  void setEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void setPassword(String password) {
    emit(state.copyWith(password: password));
  }

  Future<void> signUp() async {
    if (!_validateInputs()) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final request = SignUpRequest(
        fullName: state.fullName,
        email: state.email,
        password: state.password,
      );

      final response = await signUpUseCase(request);

      emit(state.copyWith(
        isLoading: false,
        response: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Đăng ký thất bại: ${e.toString()}',
      ));
    }
  }

  bool _validateInputs() {
    if (state.fullName.isEmpty) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập họ và tên'));
      return false;
    }
    if (state.email.isEmpty || !_isValidEmail(state.email)) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập email hợp lệ'));
      return false;
    }
    if (state.password.isEmpty || state.password.length < 6) {
      emit(state.copyWith(errorMessage: 'Mật khẩu phải có ít nhất 6 ký tự'));
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
