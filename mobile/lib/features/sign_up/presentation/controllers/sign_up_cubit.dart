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

  void setUsername(String username) {
    emit(state.copyWith(username: username));
  }

  void setEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void setPassword(String password) {
    emit(state.copyWith(password: password));
  }

  void setPhoneNumber(String phoneNumber) {
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  /// Gọi từ `TextFormField.validator`. Trả về `null` khi hợp lệ.
  /// Cubit không tự validate inputs trước khi gọi API nữa — Form
  /// validator ở Screen sẽ chặn từ đầu, tránh cubit lưu state lỗi tạm
  /// thời rồi UI phải đợi emit mới.
  Future<void> signUp() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final request = SignUpRequest(
        username: state.username.trim(),
        fullName: state.fullName.trim(),
        email: state.email.trim(),
        password: state.password,
        // PhoneNumber optional — không gửi nếu rỗng để backend
        // [Phone] validation chỉ chạy khi user nhập.
        phoneNumber: state.phoneNumber.trim().isEmpty
            ? ''
            : state.phoneNumber.trim(),
      );

      final response = await signUpUseCase(request);

      emit(state.copyWith(isLoading: false, response: response));
    } catch (e) {
      // Repo đã ném ValidationException / AppException có message rõ
      // ràng. Cubit chỉ bubble lên cho Screen xử lý qua
      // context.showAlertError(e, ...) — không bọc thêm 'Đăng ký thất
      // bại: ...' để tránh leak exception class name ra UI.
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}