import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/check_login_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../../../core/exceptions/app_exception.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase _loginUsecase;
  final LogoutUsecase _logoutUsecase;
  final CheckLoginUsecase _checkLoginUsecase;
  final SignInWithGoogleUsecase _signInWithGoogleUsecase;
  AuthCubit({
    required LoginUsecase loginUsecase,
    required LogoutUsecase logoutUsecase,
    required CheckLoginUsecase checkLoginUsecase,
    required SignInWithGoogleUsecase signInWithGoogleUsecase,
  }) : _loginUsecase = loginUsecase,
       _logoutUsecase = logoutUsecase,
       _checkLoginUsecase = checkLoginUsecase,
       _signInWithGoogleUsecase = signInWithGoogleUsecase,
       super(const AuthInitial());

  /// Kiểm tra token khi khởi động app
  Future<void> checkSession() async {
    emit(const AuthLoading());
    try {
      final isLoggedIn = await _checkLoginUsecase();
      emit(
        isLoggedIn ? const AuthAuthenticated() : const AuthUnauthenticated(),
      );
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String username, String password) async {
    emit(const AuthLoading());
    try {
      final success = await _loginUsecase(username, password);
      emit(
        success
            ? const AuthAuthenticated()
            : const AuthError('Đăng nhập thất bại'),
      );
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final success = await _signInWithGoogleUsecase();
      emit(
        success
            ? const AuthAuthenticated()
            : const AuthError('Đăng nhập Google thất bại. Vui lòng thử lại.'),
      );
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không mong muốn: $e'));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    await _logoutUsecase(callServer: true);
    emit(const AuthUnauthenticated());
  }
}
