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
      child: Container(
        width: double.infinity,
        // Decoration lives directly on the Container so the base fill is
        // sized by intrinsic content — no need to rely on a Stack's
        // StackFit.expand (which misbehaves inside an unbounded vertical
        // scroll view and triggers RenderBox-zero-size hit-test loops on
        // Flutter web).
        decoration: const BoxDecoration(color: Color(0xFF020617)),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Stack(
          // Glows do not need to fill — keep the Stack loose so it does
          // not interfere with the parent's intrinsic sizing.
          clipBehavior: Clip.none,
          children: [
            // Right-top orange glow
            Positioned(
              right: -60,
              top: -60,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFF97316).withValues(alpha: 0.22),
                        const Color(0xFFF97316).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom-left secondary glow
            Positioned(
              left: 60,
              bottom: -40,
              child: IgnorePointer(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFF97316).withValues(alpha: 0.12),
                        const Color(0xFFF97316).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Foreground content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: Color(0xFFFB923C),
                            size: 13,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Được bảo vệ bởi E-Box',
                            style: TextStyle(
                              color: Color(0xFFF1F5F9),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'SỐ DƯ KHẢ DỤNG',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatVndDigits(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        '₫',
                        style: TextStyle(
                          color: Color(0xFFF97316),
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Số dư được cập nhật ngay sau khi SePay xác nhận thanh toán.',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
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
      ),
    );
  }
}
