import 'package:flutter/material.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/locker/presentation/locker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Locker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Đổi thành login làm màn hình đầu tiên
      initialRoute: '/login', 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const LockerScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
