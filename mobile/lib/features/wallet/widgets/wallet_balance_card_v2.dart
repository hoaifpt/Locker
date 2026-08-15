import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../utils/currency.dart';

/// Light "Ví E-Box Pay" balance card — đồng bộ design system settings
/// (white card, slate border, orange accent). Chữ số dư đậm, ₫ cam.
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
    return Container(
      width: double.infinity,
      decoration: settingsCardDecoration(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Subtle orange accent strip trên đầu card để giữ "Glow" tone
          // nhưng phù hợp light theme.
          Positioned(
            left: 20,
            top: 0,
            child: Container(
              width: 56,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.settingsAccent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.settingsAccentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.settingsAccent,
                            size: 13,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Được bảo vệ bởi E-Box',
                            style: TextStyle(
                              color: AppColors.settingsAccent,
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
                const SizedBox(height: 18),
                const Text(
                  'SỐ DƯ KH� DỤNG',
                  style: TextStyle(
                    color: AppColors.settingsTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatVndDigits(balance),
                      style: const TextStyle(
                        color: AppColors.settingsTextPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '₫',
                        style: TextStyle(
                          color: AppColors.settingsAccent,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Số dư được cập nhật ngay sau khi SePay xác nhận thanh toán.',
                  style: TextStyle(
                    color: AppColors.settingsTextSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Material(
                  color: AppColors.settingsAccent,
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