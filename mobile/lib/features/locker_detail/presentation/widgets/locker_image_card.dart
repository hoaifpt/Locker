import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/locker_detail.dart';

/// Ảnh tủ + badge trạng thái ĐANG ĐÓNG / ĐANG MỞ
class LockerImageCard extends StatelessWidget {
  final LockerDetail detail;
  const LockerImageCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final isOpen = detail.doorStatus == LockerDoorStatus.open;
    return Container(
      width: 342,
      height: 342,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.primaryLight,
        image: detail.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(detail.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 4, color: Colors.white),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x7FFFEDD5),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x7FFFEDD5),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient overlay phía dưới
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x4C7C2D12), Color(0x007C2D12)],
                ),
              ),
            ),
          ),
          // Placeholder icon nếu không có ảnh
          if (detail.imageUrl == null)
            const Center(
              child: Icon(
                Icons.lock_outline,
                size: 80,
                color: AppColors.primaryBorder,
              ),
            ),
          // Badge trạng thái
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                shape: RoundedRectangleBorder(
                  side:
                      const BorderSide(width: 1, color: AppColors.primaryLight),
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                isOpen ? 'ĐANG MỞ' : 'ĐANG ĐÓNG',
                style: TextStyle(
                  color: isOpen
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEB6B4D),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
