import 'package:flutter/material.dart';

class WalletHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;

  const WalletHeader({
    super.key,
    required this.onBack,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
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
                    color: Colors.transparent,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color(0xFF1A1C1C),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Ví E-BOX',
                style: TextStyle(
                  color: Color(0xFF1A1C1C),
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
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                color: Colors.transparent,
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                size: 22,
                color: Color(0xFF1A1C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
