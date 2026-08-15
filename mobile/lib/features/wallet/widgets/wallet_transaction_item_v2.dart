import 'package:flutter/material.dart';

import '../domain/entities/wallet_transaction.dart';
import '../utils/currency.dart';
import '../utils/transaction_labels.dart';
import 'payment_status_badge.dart';

/// Web-styled transaction row. Mirrors the `filteredTransactions.map`
/// block in `web/src/features/wallet/pages/WalletPage.tsx`
/// (lines 1217-1235).
class WalletTransactionItemV2 extends StatelessWidget {
  final WalletTransaction tx;

  const WalletTransactionItemV2({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final title = (tx.description != null && tx.description!.isNotEmpty)
        ? tx.description!
        : (tx.title.isNotEmpty ? tx.title : transactionTypeLabel(tx.type));
    final time = (tx.timeLabel.isNotEmpty)
        ? tx.timeLabel
        : _formatTime(tx.createdAt);

    final amountColor = _amountColor(tx);
    final bgColor = _bgColor(tx);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              _isIncome(tx) ? Icons.south_west : Icons.north_east,
              size: 18,
              color: _isIncome(tx) ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${tx.amount > 0 ? '+' : ''}${formatVnd(tx.amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  decoration: tx.isCancelled || tx.isFailed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              PaymentStatusBadge(status: tx.status, dense: true),
            ],
          ),
        ],
      ),
    );
  }

  bool _isIncome(WalletTransaction t) {
    if (t.isIncome) return true;
    return t.amount > 0 || t.type == 0;
  }

  Color _amountColor(WalletTransaction t) {
    if (t.isCancelled) return const Color(0xFF94A3B8);
    if (t.isFailed) return const Color(0xFF94A3B8);
    if (t.isCompleted) {
      return _isIncome(t) ? const Color(0xFF059669) : const Color(0xFF0F172A);
    }
    return const Color(0xFFD97706);
  }

  Color _bgColor(WalletTransaction t) {
    if (t.isCancelled) return const Color(0xFFF1F5F9);
    if (t.isFailed) return const Color(0xFFFEF2F2);
    if (t.isCompleted) return const Color(0xFFECFDF5);
    return const Color(0xFFFFFBEB);
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
