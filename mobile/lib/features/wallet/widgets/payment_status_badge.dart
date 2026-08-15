import 'package:flutter/material.dart';

/// Pill badge for payment/transaction status. Mirrors the inline
/// `StatusBadge` in `web/src/features/wallet/pages/WalletPage.tsx`
/// (lines 62-96).
class PaymentStatusBadge extends StatelessWidget {
  final int status; // PaymentStatus int (0..4)
  final bool dense;

  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final spec = _resolve(status);
    final padH = dense ? 8.0 : 10.0;
    final padV = dense ? 3.0 : 4.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: spec.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: spec.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: spec.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            spec.label,
            style: TextStyle(
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: spec.fg,
            ),
          ),
        ],
      ),
    );
  }

  static _BadgeSpec _resolve(int status) {
    switch (status) {
      case 1:
        return const _BadgeSpec(
          label: 'Hoàn thành',
          fg: Color(0xFF059669),
          bg: Color(0x1A10B981),
          border: Color(0x3310B981),
          dot: Color(0xFF10B981),
        );
      case 3:
        return const _BadgeSpec(
          label: 'Đã huỷ',
          fg: Color(0xFF64748B),
          bg: Color(0x0F64748B),
          border: Color(0x3364748B),
          dot: Color(0xFF94A3B8),
        );
      case 2:
        return const _BadgeSpec(
          label: 'Thất bại',
          fg: Color(0xFFDC2626),
          bg: Color(0x0FEF4444),
          border: Color(0x33EF4444),
          dot: Color(0xFFEF4444),
        );
      case 4:
        return const _BadgeSpec(
          label: 'Hết hạn',
          fg: Color(0xFFDC2626),
          bg: Color(0x0FEF4444),
          border: Color(0x33EF4444),
          dot: Color(0xFFEF4444),
        );
      case 0:
      default:
        return const _BadgeSpec(
          label: 'Đang chờ',
          fg: Color(0xFFD97706),
          bg: Color(0x1AF59E0B),
          border: Color(0x33F59E0B),
          dot: Color(0xFFF59E0B),
        );
    }
  }
}

class _BadgeSpec {
  final String label;
  final Color fg;
  final Color bg;
  final Color border;
  final Color dot;
  const _BadgeSpec({
    required this.label,
    required this.fg,
    required this.bg,
    required this.border,
    required this.dot,
  });
}
