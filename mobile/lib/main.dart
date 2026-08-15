import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/routes/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/controllers/settings_cubit.dart';
import 'features/settings/presentation/controllers/settings_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 1. CẤU HÌNH XỬ LÝ THÔNG BÁO KHI APP ĐANG TẮT HOÀN TOÀN (BACKGROUND/TERMINATED)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(">>> NHẬN THÔNG BÁO CHẠY NGẦM (ID): ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase ban đầu
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('>>> FIREBASE INITIALIZED SUCCESSFULLY');

  // Đăng ký hàm xử lý chạy ngầm
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Xin quyền thông báo (Bắt buộc từ Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('>>> USER GRANTED NOTIFICATION PERMISSION');

      // Lấy Token thật của thiết bị
      String? token = await messaging.getToken();
      debugPrint('========= FCM TOKEN CỦA BẠN =========');
      debugPrint(token);
      debugPrint('======================================');

      // Mẹo: Bạn có thể lưu tạm token này vào local storage (SharedPreferences) ở đây
      // để sau này khi user Login thành công thì lấy ra bắn API register-device lên backend.

      // 2. CẤU HÌNH LẮNG NGHE REALTIME KHI ĐANG MỞ APP (FOREGROUND)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('>>> NHẬN THÔNG BÁO KHI ĐANG MỞ APP: ${message.notification?.title}');
        // Lưu ý: Trên Android, khi app đang mở (Foreground), thông báo sẽ không tự hiện trên thanh trạng thái.
        // Bạn nên xử lý hiện một Dialog hoặc Custom SnackBar/Flushbar tại đây để báo cho user.
      });

      // 3. CẤU HÌNH KHI USER BẤM VÀO THÔNG BÁO TRÊN THANH TRẠNG THÁI ĐỂ MỞ APP
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('>>> USER CLICK VÀO THÔNG BÁO ĐỂ MỞ APP: ${message.data}');
        // Logic điều hướng (Navigator) đến thẳng màn hình NotificationScreen tại đây
      });
    } else {
      debugPrint('>>> USER DENIED NOTIFICATION PERMISSION');
    }
  } catch (e) {
    debugPrint('>>> ERROR INITIALIZING FCM: $e');
  }

  // Khởi tạo dotenv và Mapbox giữ nguyên
  await dotenv.load(fileName: ".env");
  debugPrint('>>> DOTENV KEYS: ${dotenv.env.keys.toList()}');

  final mapboxToken = (dotenv.env['MAPBOX_ACCESS_TOKEN'] ??
          dotenv.env['mapbox_access_token'] ??
          dotenv.env['MAPBOX_TOKEN'] ??
          '')
      .trim();

  debugPrint('>>> MAPBOX TOKEN LENGTH: ${mapboxToken.length}');

  if (kIsWeb) {
    debugPrint('>>> MAPBOX NATIVE SETUP SKIPPED ON WEB');
  } else if (mapboxToken.isNotEmpty) {
    MapboxOptions.setAccessToken(mapboxToken);
    debugPrint('>>> MapboxOptions.setAccessToken CALLED');
  } else {
    debugPrint('>>> MAPBOX TOKEN IS EMPTY - setAccessToken NOT CALLED');
  }

  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // App-wide so the MaterialApp builder can read the current fontSize
      // and propagate the matching textScaler to every route.
      value: getIt<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (prev, next) {
          // Only rebuild when the loaded settings change (not on every
          // loading/error transition).
          if (next is SettingsLoaded && prev is SettingsLoaded) {
            return prev.fontSize != next.fontSize;
          }
          return false;
        },
        builder: (context, state) {
          final textScaleFactor =
              state is SettingsLoaded && state.fontSize == FontSize.easyRead
                  ? 1.25
                  : 1.0;
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.light,
            initialRoute: AppRouter.initialRoute,
            routes: AppRouter.routes,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: TextScaler.linear(textScaleFactor),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
