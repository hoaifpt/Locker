import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/locker_slot.dart';

/// Card phía dưới màn hình — hiện tủ đang chọn + nút Mở Tủ
class SelectedLockerCard extends StatelessWidget {
  final LockerSlot slot;
  final bool isOpening;
  final VoidCallback onOpenTap;

  const SelectedLockerCard({
    super.key,
    required this.slot,
    required this.isOpening,
    required this.onOpenTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.primaryLight),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x1E000000),
              blurRadius: 30,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon tủ
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.iconSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Thông tin tủ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ĐANG CHỌN: TỦ ${slot.code}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                      letterSpacing: 0.50,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slot.locationName ?? 'Cửa hàng tiện lợi',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (slot.locationAddress != null)
                    Text(
                      slot.locationAddress!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Nút Chi tiết
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                '/locker-detail',
                arguments: slot.id,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: const Text(
                  'Chi tiết',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Nút Mở Tủ
            GestureDetector(
              onTap: isOpening ? null : onOpenTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isOpening ? AppColors.primaryLight : AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 15,
                      offset: Offset(0, 10),
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: isOpening
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Mở Tủ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          height: 1.43,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
