import 'package:flutter/material.dart';

/// Card hiển thị một chỉ số (PIN%, CÒN LẠI) — không wrap Expanded,
/// caller tự quyết định layout (thường dùng bên trong Row + Expanded)
class LockerStatCard extends StatelessWidget {
  final String label; // "PIN", "CÒN LẠI"
  final String value; // "85%", "14h"
  const LockerStatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFFFF7ED)),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x66FFEDD5),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x66FFEDD5),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFF7E5F),
              fontSize: 12,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 24,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
