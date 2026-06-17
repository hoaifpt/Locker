import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/routes/injection.dart';
import 'core/theme/app_theme.dart';

void main() {
  // Đảm bảo các binding của Flutter đã được khởi tạo trước khi chạy app
  WidgetsFlutterBinding.ensureInitialized();

  // Gọi hàm cấu hình dependency injection
  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.light,
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
