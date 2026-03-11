import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bottom controls: Thư viện | Capture button | Lịch sử + "Nhập mã thủ công"
class ScannerBottomBar extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCapture;
  final VoidCallback onHistory;
  final VoidCallback onManualEntry;

  const ScannerBottomBar({
    super.key,
    required this.onGallery,
    required this.onCapture,
    required this.onHistory,
    required this.onManualEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x001A120E), Color(0xFF1A120E)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Thư viện
              _SideButton(
                label: 'Thư viện',
                icon: Icons.photo_library_rounded,
                onTap: onGallery,
              ),
              const SizedBox(width: 32),
              // Big capture button
              GestureDetector(
                onTap: onCapture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF8A65), AppColors.scannerAccentDark],
                    ),
                    shape: const OvalBorder(
                      side: BorderSide(width: 4, color: AppColors.scannerBg),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x4DFF7043),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Lịch sử
              _SideButton(
                label: 'Lịch sử',
                icon: Icons.history_rounded,
                onTap: onHistory,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Nhập mã thủ công pill button
          GestureDetector(
            onTap: onManualEntry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: ShapeDecoration(
                color: const Color(0x19FF7043),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0x33FF7043)),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text(
                'Nhập mã thủ công',
                style: TextStyle(
                  color: AppColors.scannerAccentLight,
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Square icon+label button on the sides
class _SideButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SideButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: ShapeDecoration(
              color: const Color(0x7F3E2F28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
