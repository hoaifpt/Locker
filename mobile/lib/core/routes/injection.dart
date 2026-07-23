import 'package:get_it/get_it.dart';
import 'package:locker_mobile/features/auth/data/auth_repository.dart';
import 'package:locker_mobile/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:locker_mobile/features/auth/domain/usecases/check_login_usecase.dart';
import 'package:locker_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:locker_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:locker_mobile/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:locker_mobile/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:locker_mobile/features/auth/presentation/controllers/auth_cubit.dart';
import 'package:locker_mobile/features/auth/presentation/controllers/verify_email_cubit.dart';
import 'package:locker_mobile/features/qr_scanner/data/qr_scanner_repository.dart';
import 'package:locker_mobile/features/qr_scanner/domain/repositories/i_qr_scanner_repository.dart';
import 'package:locker_mobile/features/qr_scanner/domain/usecases/validate_qr_code_usecase.dart';
import 'package:locker_mobile/features/qr_scanner/presentation/controllers/qr_scanner_cubit.dart';
import 'package:locker_mobile/features/sign_up/data/sign_up_repository.dart';
import 'package:locker_mobile/features/sign_up/domain/repositories/i_sign_up_repository.dart';
import 'package:locker_mobile/features/sign_up/domain/usecases/sign_up_usecase.dart';
import 'package:locker_mobile/features/sign_up/presentation/controllers/sign_up_cubit.dart';

import 'package:locker_mobile/features/wallet/data/wallet_repository.dart';
import 'package:locker_mobile/features/wallet/domain/repositories/i_wallet_repository.dart';
import 'package:locker_mobile/features/wallet/domain/usecases/get_wallet_overview_usecase.dart';
import 'package:locker_mobile/features/wallet/presentation/controllers/wallet_cubit.dart';

import '../../features/home/data/home_repository.dart';
import '../../features/home/data/user_repository.dart';
import '../../features/home/domain/repositories/i_home_repository.dart';
import '../../features/home/domain/repositories/i_user_repository.dart';
import '../../features/home/domain/usecases/get_active_lockers_usecase.dart';
import '../../features/home/domain/usecases/get_nearby_lockers_usecase.dart';
import '../../features/home/domain/usecases/get_user_profile_usecase.dart';
import '../../features/home/presentation/controllers/home_cubit.dart';

final getIt = GetIt.instance;

/// Configures dependencies for the entire application.
///
/// This function should be called once at application startup.
void configureDependencies() {
  //========================================================================
  //                                 AUTH
  //========================================================================

  // Repositories
  // Registering AuthRepository as a lazy singleton for IAuthRepository.
  // It will be created only once when it's first requested.
  getIt.registerLazySingleton<IAuthRepository>(() => AuthRepository());

  // Use Cases
  // Usecases are also registered as lazy singletons as they are stateless.
  getIt.registerLazySingleton(() => LoginUsecase(getIt()));
  getIt.registerLazySingleton(() => LogoutUsecase(getIt()));
  getIt.registerLazySingleton(() => CheckLoginUsecase(getIt()));
  getIt.registerLazySingleton(() => SignInWithGoogleUsecase(getIt()));
  getIt.registerLazySingleton(
    () => ResendVerificationEmailUseCase(getIt<IAuthRepository>()),
  );

  // Cubits
  // Cubits are registered as factories because they hold state and a new
  // instance should be created for each feature/screen that needs it.
  getIt.registerFactory(
    () => AuthCubit(
      loginUsecase: getIt(),
      logoutUsecase: getIt(),
      checkLoginUsecase: getIt(),
      signInWithGoogleUsecase: getIt(),
    ),
  );
  getIt.registerFactory(
    () => VerifyEmailCubit(resendVerificationEmailUseCase: getIt()),
  );

  //========================================================================
  //                               SIGN UP
  //========================================================================

  // Repositories
  getIt.registerLazySingleton<ISignUpRepository>(() => SignUpRepository());

  // Use Cases
  getIt.registerLazySingleton(() => SignUpUseCase(repository: getIt()));

  // Cubits
  getIt.registerFactory(() => SignUpCubit(signUpUseCase: getIt()));

  //========================================================================
  //                                 WALLET
  //========================================================================

  // Repositories
  getIt.registerLazySingleton<IWalletRepository>(() => WalletRepository());

  // Use Cases
  getIt.registerLazySingleton(
    () => GetWalletOverviewUseCase(repository: getIt()),
  );

  // Cubits
  getIt.registerFactory(
    () => WalletCubit(getWalletOverview: getIt(), walletRepository: getIt()),
  );

  //========================================================================
  //                              QR SCANNER
  //========================================================================

  // Repositories
  getIt.registerLazySingleton<IQrScannerRepository>(
    () => QrScannerRepository(),
  );

  // Use Cases
  getIt.registerLazySingleton(() => ValidateQrCodeUsecase(getIt()));

  // Cubits
  getIt.registerFactory(() => QrScannerCubit(validateQrCode: getIt()));

  //========================================================================
  //                                 HOME
  //========================================================================

  // Repositories
  getIt.registerLazySingleton<IHomeRepository>(() => HomeRepository());
  getIt.registerLazySingleton<IUserRepository>(() => UserRepository());

  // Use Cases
  getIt.registerLazySingleton(() => GetActiveLockers(getIt<IHomeRepository>()));
  getIt.registerLazySingleton(() => GetNearbyLockers(getIt<IHomeRepository>()));
  getIt.registerLazySingleton(() => GetUserProfile(getIt<IUserRepository>()));

  // Cubits
  getIt.registerFactory(
    () => HomeCubit(
      getActiveLockers: getIt(),
      getNearbyLockers: getIt(),
      getUserProfile: getIt(),
    ),
  );
}
