import 'package:flutter/material.dart';

class NotificationHeader extends StatelessWidget {
  final VoidCallback onMarkAllAsRead;
  final VoidCallback onBackToHome;

  const NotificationHeader({
    super.key,
    required this.onMarkAllAsRead,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBackToHome,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    color: Color(0xFFF27B50),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông báo',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.60,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onMarkAllAsRead,
            child: const Text(
              'Đánh dấu đã đọc',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF27B50),
                fontSize: 14,
                fontFamily: 'Aleo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
