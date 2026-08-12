import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> login(String username, String password) async {
    emit(AuthLoading());

    try {
      final success = await loginUsecase(username, password);

      if (!success) {
        emit(const AuthError('Tài khoản hoặc mật khẩu không đúng'));
        return;
      }

      final user = await getUserProfileUsecase();

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      final user = await signInWithGoogleUsecase.call();

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
