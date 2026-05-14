import 'package:flutter/material.dart';

class LockerIdBadge extends StatelessWidget {
  final String lockerId;

  const LockerIdBadge({super.key, required this.lockerId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F4),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF9D4320),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LOCKER ID: $lockerId',
            style: const TextStyle(
              color: Color(0xFF52443E),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.28,
            ),
          ),
        ],
      ),
    );
  }
}
