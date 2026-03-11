import 'package:flutter/material.dart';

/// Bảng màu dùng chung toàn app — lấy từ design system Figma
class AppColors {
  // Brand orange
  static const Color primary = Color(0xFFFB923C);
  static const Color primaryLight = Color(0xFFFFEDD5);
  static const Color primaryBorder = Color(0xFFFED7AA);
  static const Color primaryGlow = Color(0xFFFDBA74);

  // Backgrounds
  static const Color warmBackground = Color(0xFFFFFBF2);
  static const Color surface = Colors.white;
  static const Color iconSurface = Color(0xFFFFF7ED);

  // Locker status colors
  static const Color lockerMine = Color(0xFFFB923C); // TỦ CỦA BẠN
  static const Color lockerAvailable = Color(0xFFFFEDD5); // TRỐNG
  static const Color lockerOccupied = Color(0xFFE7E5E4); // ĐÃ ĐẶT

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textDark = Color(0xFF431407);
  static const Color textOrange = Color(0xFF9A3412);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // UI
  static const Color divider = Color(0xFFF1F5F9);

  // QR Scanner dark theme
  static const Color scannerBg = Color(0xFF1A120E);
  static const Color scannerSurface = Color(0xFF3E2F28);
  static const Color scannerSurface2 = Color(0xFF2D241F);
  static const Color scannerAccent = Color(0xFFFF7043);
  static const Color scannerAccentLight = Color(0xFFFFAB91);
  static const Color scannerAccentDark = Color(0xFFE64A19);
}
