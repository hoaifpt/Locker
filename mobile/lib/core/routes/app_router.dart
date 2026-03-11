import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/locker/presentation/locker_screen.dart';
import '../../features/locker_detail/presentation/pages/locker_detail_page.dart';
import '../../features/locker_map/presentation/pages/locker_map_page.dart';
import '../../features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static const initialRoute = '/login';

  static Map<String, WidgetBuilder> get routes => {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/lockers': (context) => const LockerScreen(),
        '/locker-map': (context) => const LockerMapPage(),
        '/locker-detail': (context) => LockerDetailPage(
              lockerId: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/qr-scanner': (context) => const QrScannerPage(),
        '/settings': (context) => const SettingsPage(),
      };
}
