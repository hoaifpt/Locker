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

  // ─── Settings-style design tokens ─────────────────────────────────────────
  // Shared by Profile, Personal Info, Change Password, Feedback so they
  // all look like the same product, not four separate apps.
  static const Color settingsBackground = Color(0xFFF8FAFC); // slate-50
  static const Color settingsCardBorder = Color(0xFFE2E8F0); // slate-200
  static const Color settingsDivider = Color(0xFFF1F5F9); // slate-100
  static const Color settingsShadow = Color(0x0C000000); // 8% black
  static const Color settingsShadowSmall = Color(0x0C000000);
  static const Color settingsAccent = Color(0xFFF97316); // orange-500
  static const Color settingsAccentSoft = Color(0xFFFFF7ED); // orange-50
  static const Color settingsTextPrimary = Color(0xFF0F172A); // slate-900
  static const Color settingsTextSecondary = Color(0xFF64748B); // slate-500
  static const Color settingsTextMuted = Color(0xFF94A3B8); // slate-400
  static const Color settingsBackIcon = Color(0xFF334155); // slate-700
}

/// Card giống settings: white, border slate-200, bo 20, shadow nhẹ.
BoxDecoration settingsCardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.settingsCardBorder),
      boxShadow: const [
        BoxShadow(
          color: AppColors.settingsShadow,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );

/// Nút back giống settings: 40×40, white, bo 12, shadow rất nhẹ.
class SettingsBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const SettingsBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.settingsCardBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.settingsShadowSmall,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: AppColors.settingsBackIcon,
          ),
        ),
      ),
    );
  }
}

/// Top bar giống settings: white mờ, có nút back + icon accent + title.
class SettingsTopBar extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onBack;

  const SettingsTopBar({
    super.key,
    required this.title,
    required this.icon,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          SettingsBackButton(onTap: onBack),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: AppColors.settingsAccent),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.settingsTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Input field style giống settings card: white, border slate-200, bo 16,
/// focus border orange.
InputDecoration settingsInputDecoration({
  String? hintText,
  Widget? suffixIcon,
  String? labelText,
}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: hintText,
    labelText: labelText,
    hintStyle: const TextStyle(
      color: AppColors.settingsTextMuted,
      fontSize: 14,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.settingsCardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: AppColors.settingsAccent,
        width: 1.5,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.settingsCardBorder),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
    ),
    suffixIcon: suffixIcon,
  );
}

/// Primary button style giống settings: orange, white text, bo 16.
ButtonStyle settingsPrimaryButtonStyle() => ElevatedButton.styleFrom(
      backgroundColor: AppColors.settingsAccent,
      foregroundColor: Colors.white,
      disabledBackgroundColor: const Color(0xFFFDBA74),
      disabledForegroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
