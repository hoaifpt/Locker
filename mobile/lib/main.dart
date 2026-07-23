import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/routes/injection.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('>>> FIREBASE INITIALIZED SUCCESSFULLY');
  await dotenv.load(fileName: ".env");

  debugPrint('>>> DOTENV KEYS: ${dotenv.env.keys.toList()}');

  final mapboxToken =
      (dotenv.env['MAPBOX_ACCESS_TOKEN'] ??
              dotenv.env['mapbox_access_token'] ??
              dotenv.env['MAPBOX_TOKEN'] ??
              '')
          .trim();

  debugPrint('>>> MAPBOX TOKEN LENGTH: ${mapboxToken.length}');

  if (mapboxToken.isNotEmpty) {
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
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.light,
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
