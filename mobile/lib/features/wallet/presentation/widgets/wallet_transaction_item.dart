import 'package:flutter/material.dart';

import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionItem extends StatelessWidget {
  final WalletTransaction transaction;

  const WalletTransactionItem({super.key, required this.transaction});

  String _formatAmount(int amount) {
    final prefix = amount >= 0 ? '+' : '-';
    final value = amount.abs().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '$prefix${value}đ';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final amountColor =
        isIncome ? const Color(0xFF16A34A) : const Color(0xFF1A1C1C);
    final iconBackground =
        isIncome ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final iconColor =
        isIncome ? const Color(0xFF16A34A) : const Color(0xFFFB923C);
    final icon =
        isIncome ? Icons.savings_outlined : Icons.receipt_long_outlined;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: ShapeDecoration(
                  color: iconBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      color: Color(0xFF1A1C1C),
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF52443E),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatAmount(transaction.amount),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: amountColor,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.timeLabel,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF52443E),
                  fontSize: 10,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: -0.25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
