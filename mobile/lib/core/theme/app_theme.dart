import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFFEB6C4B);
  static const _secondary = Color(0xFFFD9C74);
  static const _background = Color(0xFFFDF7F3);
  static const _surface = Colors.white;
  static const _textPrimary = Color(0xFF1C1C1E);
  static const _textSecondary = Color(0xFF6C6C6C);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: _primary,
        secondary: _secondary,
        background: _background,
        surface: _surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: _textPrimary,
        onSurface: _textPrimary,
      ),
      scaffoldBackgroundColor: _background,
      textTheme: base.textTheme
          .apply(
            fontFamily: 'Roboto',
            bodyColor: _textPrimary,
            displayColor: _textPrimary,
          )
          .copyWith(
            titleLarge: base.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
            bodyMedium: base.textTheme.bodyMedium?.copyWith(
              color: _textSecondary,
            ),
            labelLarge: base.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 1.4),
        ),
        hintStyle: base.textTheme.bodyMedium?.copyWith(color: _textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
