import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/locker/presentation/locker_screen.dart';

class AppRouter {
  static const initialRoute = '/login';

  static Map<String, WidgetBuilder> get routes => {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const LockerScreen(),
      };
}
