import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Chú thích màu sắc: TỦ CỦA BẠN / TRỐNG / ĐÃ ĐẶT
class LockerLegend extends StatelessWidget {
  const LockerLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _LegendItem(
          label: 'TỦ CỦA BẠN',
          dotColor: AppColors.lockerMine,
          ringColor: AppColors.primaryLight,
        ),
        _LegendItem(
          label: 'TRỐNG',
          dotColor: AppColors.lockerAvailable,
          ringColor: Color(0xFFFFF7ED),
          hasBorder: true,
          borderColor: AppColors.primaryBorder,
        ),
        _LegendItem(
          label: 'ĐÃ ĐẶT',
          dotColor: AppColors.lockerOccupied,
          ringColor: Color(0xFFF9FAFB),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color dotColor;
  final Color ringColor;
  final bool hasBorder;
  final Color? borderColor;

  const _LegendItem({
    required this.label,
    required this.dotColor,
    required this.ringColor,
    this.hasBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: hasBorder && borderColor != null
                ? Border.all(color: borderColor!, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: ringColor,
                blurRadius: 0,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.50,
            letterSpacing: 0.55,
          ),
        ),
      ],
    );
  }
}
