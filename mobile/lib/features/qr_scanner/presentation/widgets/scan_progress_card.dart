import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Card hiển thị trạng thái scanning: "Đang nhận diện..." + progress bar
class ScanProgressCard extends StatelessWidget {
  final double progress; // 0.0 → 1.0
  final String status; // text hiển thị

  const ScanProgressCard({
    super.key,
    this.progress = 0.75,
    this.status = 'Đang nhận diện...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xCC2D241F),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x33FF7043)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const ShapeDecoration(
                      color: AppColors.scannerAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9999)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.scannerAccent,
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Container(
            width: double.infinity,
            height: 6,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9999)),
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.scannerAccentDark,
                      AppColors.scannerAccent
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9999)),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x7FFF7043),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
