import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/locker_slot.dart';

/// Một ô tủ trên sơ đồ, màu sắc phản ánh trạng thái (mine/available/occupied)
class LockerCell extends StatelessWidget {
  final LockerSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const LockerCell({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = slot.status == LockerStatus.mine;
    final isAvail = slot.status == LockerStatus.available;

    final BoxDecoration decoration;
    final Color textColor;

    if (isMine) {
      textColor = Colors.white;
      decoration = BoxDecoration(
        color: AppColors.lockerMine,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryGlow,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.primaryGlow,
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: AppColors.primaryLight,
            blurRadius: 0,
            spreadRadius: 4,
          ),
        ],
      );
    } else if (isAvail) {
      textColor = AppColors.textOrange;
      decoration = BoxDecoration(
        color: AppColors.lockerAvailable,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      );
    } else {
      textColor = AppColors.textMuted;
      decoration = BoxDecoration(
        color: AppColors.lockerOccupied,
        borderRadius: BorderRadius.circular(16),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: decoration,
        child: Stack(
          children: [
            // Indicator dot của tủ đang là của mình
            if (isMine)
              const Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              ),
            Center(
              child: Text(
                slot.code,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
