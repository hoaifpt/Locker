import 'package:flutter/material.dart';

class SecurityPrivacyHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;

  const SecurityPrivacyHeader({
    super.key,
    required this.onBack,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF1A1C1C),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Bảo mật & Quyền riêng tư',
                style: TextStyle(
                  color: Color(0xFFFB923C),
                  fontSize: 20,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onMore,
            child: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFF1A1C1C),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
