import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/locker_map_state.dart';

/// Thanh filter: Gần nhất / Tủ lớn / Tủ nhỏ
class LockerFilterBar extends StatelessWidget {
  final LockerFilter activeFilter;
  final ValueChanged<LockerFilter> onFilterChanged;

  const LockerFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'Gần nhất',
          filter: LockerFilter.nearest,
          activeFilter: activeFilter,
          onTap: onFilterChanged,
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Tủ lớn',
          filter: LockerFilter.large,
          activeFilter: activeFilter,
          onTap: onFilterChanged,
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Tủ nhỏ',
          filter: LockerFilter.small,
          activeFilter: activeFilter,
          onTap: onFilterChanged,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final LockerFilter filter;
  final LockerFilter activeFilter;
  final ValueChanged<LockerFilter> onTap;

  const _FilterChip({
    required this.label,
    required this.filter,
    required this.activeFilter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = filter == activeFilter;
    return GestureDetector(
      onTap: () => onTap(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: ShapeDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isActive ? Colors.transparent : AppColors.primaryBorder,
            ),
            borderRadius: BorderRadius.circular(9999),
          ),
          shadows: isActive
              ? const [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                    spreadRadius: -2,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textDark,
            fontSize: 14,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
      ),
    );
  }
}
