import 'package:flutter/material.dart';

import '../utils/currency.dart';

/// Dark "Ví E-Box Pay" balance card. Mirrors the inline balance block in
/// `web/src/features/wallet/pages/WalletPage.tsx` (lines 537-574) — slate
/// background with orange glow accents and a large bold amount.
class WalletBalanceCardV2 extends StatelessWidget {
  final int balance;
  final VoidCallback onTopUp;

  const WalletBalanceCardV2({
    super.key,
    required this.balance,
    required this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // Base slate background
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF0B1220)),
          ),
          // Right-top orange glow (subtle, no blur API needed)
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF97316).withValues(alpha: 0.18),
                    const Color(0xFFF97316).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Bottom-left secondary glow
          Positioned(
            left: 60,
            bottom: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF97316).withValues(alpha: 0.10),
                    const Color(0xFFF97316).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: const Color(0xFFFB923C),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Được bảo vệ bởi E-Box',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Số dư khả dụng',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatVndDigits(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '₫',
                        style: TextStyle(
                          color: Color(0xFFF97316),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Số dư được cập nhật ngay sau khi SePay xác nhận thanh toán.',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),
                Material(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onTopUp,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Nạp tiền vào ví',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
