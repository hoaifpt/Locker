import 'package:flutter/material.dart';

import '../../domain/entities/storage_duration.dart';

class DurationButton extends StatelessWidget {
  final StorageDuration duration;
  final bool isSelected;
  final VoidCallback onTap;

  const DurationButton({
    super.key,
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFFB923C) : const Color(0xFFF8FAFC),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected
                  ? const Color(0xFFFB923C)
                  : const Color(0xFFF1F5F9),
            ),
            borderRadius: BorderRadius.circular(9999),
          ),
          shadows: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x33FB923C),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: -4,
                  ),
                  const BoxShadow(
                    color: Color(0x33FB923C),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                    spreadRadius: -3,
                  ),
                ]
              : [],
        ),
        child: Text(
          duration.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
