import 'package:flutter/material.dart';

class PaymentFailedSummaryCard extends StatelessWidget {
  final String amount;
  final String paymentMethod;
  final String lockerHub;
  final String reason;
  final String referenceCode;

  const PaymentFailedSummaryCard({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.lockerHub,
    required this.reason,
    required this.referenceCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoRow(
              label: 'Số tiền cần thanh toán', value: amount, emphasized: true),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          _InfoRow(label: 'Phương thức', value: paymentMethod),
          const SizedBox(height: 12),
          _InfoRow(label: 'Locker Hub', value: lockerHub),
          const SizedBox(height: 12),
          _InfoRow(label: 'Lý do thất bại', value: reason),
          const SizedBox(height: 12),
          _InfoRow(label: 'Mã tham chiếu', value: referenceCode),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: emphasized
                  ? const Color(0xFFE63946)
                  : const Color(0xFF111827),
              fontSize: emphasized ? 18 : 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }
}
