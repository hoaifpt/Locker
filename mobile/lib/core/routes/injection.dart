import 'package:get_it/get_it.dart';
import 'package:locker_mobile/core/network/api_client.dart';
import 'package:locker_mobile/features/auth/data/auth_repository.dart';
import 'package:locker_mobile/features/notifications/data/notification_repository.dart';
import 'package:locker_mobile/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:locker_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:locker_mobile/features/notifications/domain/usecases/mark_all_as_read_usecase.dart';
import 'package:locker_mobile/features/notifications/domain/usecases/mark_as_read_usecase.dart';
import 'package:locker_mobile/features/notifications/domain/usecases/register_device_usecase.dart';
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

import '../../features/notifications/presentation/controllers/notification_cubit.dart';
import 'package:locker_mobile/core/constants/app_constants.dart';
import 'package:locker_mobile/features/wallet/data/signalr_payment_realtime_service.dart';
import 'package:locker_mobile/features/wallet/data/wallet_repository.dart';
import 'package:locker_mobile/features/wallet/domain/repositories/i_wallet_repository.dart';
import 'package:locker_mobile/features/wallet/domain/services/payment_realtime_service.dart';
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

import '../../features/change_password/data/repositories/change_password_repository_impl.dart';
import '../../features/change_password/domain/repositories/i_change_password_repository.dart';
import '../../features/change_password/domain/usecases/forgot_password_usecase.dart';
import '../../features/change_password/domain/usecases/reset_password_usecase.dart';
import '../../features/change_password/presentation/controllers/forgot_password_cubit.dart';
import '../../features/feedback/data/feedback_repository.dart';
import '../../features/feedback/domain/repositories/i_feedback_repository.dart';
import '../../features/feedback/domain/usecases/get_my_feedback_usecase.dart';
import '../../features/feedback/domain/usecases/upsert_feedback_usecase.dart';
import '../../features/feedback/presentation/controllers/feedback_cubit.dart';

import '../../features/settings/data/settings_repository.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../features/settings/domain/usecases/get_preferences_usecase.dart';
import '../../features/settings/domain/usecases/get_profile_usecase.dart';
import '../../features/settings/domain/usecases/logout_settings_usecase.dart';
import '../../features/settings/domain/usecases/update_preferences_usecase.dart';
import '../../features/settings/presentation/controllers/settings_cubit.dart';

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
  getIt.registerLazySingleton(
    () => SignInWithGoogleUsecase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => ResendVerificationEmailUseCase(getIt<IAuthRepository>()),
  );

  // Cubits
  // Cubits are registered as factories because they hold state and a new
  // instance should be created for each feature/screen that needs it.
  // Single app-wide instance so the AuthGate in main.dart can listen to
  // auth changes (login/logout/session-restored) and swap the root route
  // without re-creating the cubit on every navigation. The cubit auto-runs
  // `checkSession()` on first creation to restore the saved token.
  getIt.registerLazySingleton(
    () => AuthCubit(
      loginUsecase: getIt(),
      logoutUsecase: getIt(),
      checkLoginUsecase: getIt(),
      registerDeviceUsecase: getIt(),
      signInWithGoogleUsecase: getIt(),
      getUserProfileUsecase: getIt(),
    )..checkSession(),
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

  // SignalR realtime service for wallet top-up.
  // Registered as a lazy singleton so its `tokenProvider` closure always
  // reads the freshest token from the shared ApiClient (works across
  // login/logout/token-refresh). The hub URL mirrors
  // `web/src/features/wallet/api/paymentRealtime.ts` — strip `/api` from
  // apiBaseUrl, then append `/hubs/notifications`.
  getIt.registerLazySingleton<IPaymentRealtimeService>(() {
    final apiBase = AppConstants.apiBaseUrl;
    var base = apiBase;
    if (base.endsWith('/api')) base = base.substring(0, base.length - 4);
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return SignalRPaymentRealtimeService(
      hubUrl: '$base/hubs/notifications',
      tokenProvider: () async => ApiClient().accessToken,
    );
  });

  // Use Cases
  getIt.registerLazySingleton(
    () => GetWalletOverviewUseCase(repository: getIt()),
  );

  // Cubits
  getIt.registerFactory(
    () => WalletCubit(
      getWalletOverview: getIt(),
      walletRepository: getIt(),
      realtimeService: getIt<IPaymentRealtimeService>(),
    ),
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

  //========================================================================
  //                             NOTIFICATIONS
  //========================================================================

  // Repositories
  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepository(),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetNotificationsUsecase(repository: getIt()),
  );
  getIt.registerLazySingleton(() => MarkAsReadUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => MarkAllAsReadUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => RegisterDeviceUsecase(repository: getIt()));

  // Cubits
  getIt.registerFactory(
    () => NotificationCubit(
      getNotifications: getIt(),
      markAsRead: getIt(),
      markAllAsRead: getIt(),
      registerDevice: getIt(),
    ),
  );

  //========================================================================
  //                          FORGOT PASSWORD
  //========================================================================
  getIt.registerLazySingleton<IChangePasswordRepository>(
    () => ChangePasswordRepositoryImpl(),
  );
  getIt.registerLazySingleton(() => ForgotPasswordUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => ResetPasswordUseCase(repository: getIt()));

  getIt.registerFactory(
    () => ForgotPasswordCubit(
      forgotPasswordUseCase: getIt(),
      resetPasswordUseCase: getIt(),
    ),
  );

  //========================================================================
  //                               FEEDBACK
  //========================================================================
  getIt.registerLazySingleton<IFeedbackRepository>(() => FeedbackRepository());
  getIt.registerLazySingleton(
    () => GetMyFeedbackUsecase(getIt<IFeedbackRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpsertFeedbackUsecase(getIt<IFeedbackRepository>()),
  );
  getIt.registerFactory(
    () => FeedbackCubit(getMyFeedback: getIt(), upsertFeedback: getIt()),
  );

  //========================================================================
  //                                SETTINGS
  //========================================================================

  // Single app-wide instance so the MaterialApp builder can listen for
  // fontSize changes and propagate the textScaler to every route. The
  // Settings page reuses the same instance instead of creating a fresh
  // cubit per visit.
  getIt.registerLazySingleton<ISettingsRepository>(() => SettingsRepository());
  getIt.registerLazySingleton(
    () => GetProfileUsecase(getIt<ISettingsRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPreferencesUsecase(getIt<ISettingsRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdatePreferencesUsecase(getIt<ISettingsRepository>()),
  );
  getIt.registerLazySingleton(
    () => LogoutSettingsUsecase(getIt<ISettingsRepository>()),
  );

  getIt.registerLazySingleton(
    () => SettingsCubit(
      getProfile: getIt(),
      getPreferences: getIt(),
      updatePreferences: getIt(),
      logout: getIt(),
    )..load(),
  );
}
