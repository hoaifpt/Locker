import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // --- Theme shortcuts ---
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;

  // --- Size ---
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // --- SnackBar ---
  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void showSnackError(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: colors.error,
      ));
  }

  void showSnackSuccess(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
      ));
  }

  // --- Navigation shortcuts ---
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) =>
      Navigator.of(this).push(MaterialPageRoute(builder: (_) => page));
  Future<T?> pushNamed<T>(String route) =>
      Navigator.of(this).pushNamed(route) as Future<T?>;
  void pushReplacementNamed(String route) =>
      Navigator.of(this).pushReplacementNamed(route);
}
