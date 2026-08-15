import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:locker_mobile/core/exceptions/app_exception.dart';
import 'package:locker_mobile/features/auth/domain/usecases/check_login_usecase.dart';
import 'package:locker_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:locker_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:locker_mobile/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:locker_mobile/features/home/domain/usecases/get_user_profile_usecase.dart';
import 'package:locker_mobile/features/notifications/domain/usecases/register_device_usecase.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final CheckLoginUsecase checkLoginUsecase;
  final RegisterDeviceUsecase registerDeviceUsecase;
  final SignInWithGoogleUsecase signInWithGoogleUsecase;
  final GetUserProfile getUserProfileUsecase;

  AuthCubit({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.checkLoginUsecase,
    required this.registerDeviceUsecase,
    required this.signInWithGoogleUsecase,
    required this.getUserProfileUsecase,
  }) : super(AuthInitial());

  /// Kiểm tra token đã lưu trong SharedPreferences khi app khởi động.
  /// Nếu còn token → fetch profile → AuthAuthenticated.
  /// Nếu không → AuthUnauthenticated (show LoginPage).
  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      final hasToken = await checkLoginUsecase();
      if (!hasToken) {
        emit(const AuthUnauthenticated());
        return;
      }
      final user = await getUserProfileUsecase();
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Token hết hạn / không hợp lệ → trở về login.
      emit(const AuthUnauthenticated());
    }
  }

  /// Returns true on success, throws on failure so the caller (LoginPage)
  /// can hand the raw exception to `context.showAlertError()` for friendly
  /// mapping. We do NOT swallow errors into `AuthError.message` here —
  /// keeping the exception object intact preserves type information
  /// (`UnauthorizedException`, `DioException`, …) so the friendly mapper
  /// can render the right Vietnamese copy.
  Future<bool> login(String username, String password) async {
    emit(AuthLoading());

    final success = await loginUsecase(username, password);

    if (!success) {
      // Backend didn't return a token — treat as bad credentials.
      throw UnauthorizedException('Sai tài khoản hoặc mật khẩu.');
    }

    final user = await getUserProfileUsecase();
    emit(AuthAuthenticated(user));
    return true;
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final user = await signInWithGoogleUsecase.call();
    emit(AuthAuthenticated(user));
  }

  /// Đăng xuất: xoá token → emit AuthUnauthenticated. AuthGate sẽ tự
  /// đẩy về LoginPage.
  Future<void> logout({bool callServer = false}) async {
    try {
      await logoutUsecase(callServer: callServer);
    } catch (_) {
      // Bỏ qua l�i — vẫn tiếp tục clear local state.
    }
    emit(const AuthUnauthenticated());
  }
}