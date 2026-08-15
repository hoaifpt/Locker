import 'package:flutter/material.dart';

import '../domain/entities/wallet_transaction.dart';
import '../utils/transaction_labels.dart';
import 'wallet_transaction_item_v2.dart';

/// White card containing the "Lịch sử giao dịch" section with status
/// filter chips and a transaction list. Mirrors the section block in
/// `web/src/features/wallet/pages/WalletPage.tsx` (lines 1173-1238).
class WalletTransactionsSection extends StatefulWidget {
  final List<WalletTransaction> transactions;
  final String statusFilter;
  final ValueChanged<String> onStatusFilterChanged;
  final VoidCallback onViewAll;
  final Future<void> Function() onRefresh;
  final bool isLoading;

  const WalletTransactionsSection({
    super.key,
    required this.transactions,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.onViewAll,
    required this.onRefresh,
    this.isLoading = false,
  });

  @override
  State<WalletTransactionsSection> createState() =>
      _WalletTransactionsSectionState();
}

class _WalletTransactionsSectionState extends State<WalletTransactionsSection> {
  List<WalletTransaction> _filtered() {
    if (widget.statusFilter == 'all') return widget.transactions;
    final want = int.tryParse(widget.statusFilter);
    if (want == null) return widget.transactions;
    return widget.transactions.where((t) => t.status == want).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: const Color(0xFFF97316),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Lịch sử giao dịch',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Các giao dịch gần đây của ví',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${filtered.length} giao dịch',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in kTransactionStatusFilters)
                  _FilterChip(
                    label: f.label,
                    selected: widget.statusFilter == f.value,
                    onTap: () => widget.onStatusFilterChanged(f.value),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.isLoading && widget.transactions.isEmpty)
              const _LoadingList()
            else if (filtered.isEmpty)
              _EmptyState(filter: widget.statusFilter)
            else
              Column(
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    WalletTransactionItemV2(tx: filtered[i]),
                    if (i != filtered.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF1F5F9),
                      ),
                  ],
                ],
              ),
            const SizedBox(height: 8),
            if (filtered.length > 5)
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: widget.onViewAll,
                  child: const Text(
                    'Xem tất cả lịch sử',
                    style: TextStyle(
                      color: Color(0xFF87503C),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF97316) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final f = kTransactionStatusFilters
        .where((c) => c.value == filter)
        .firstOrNull;
    final label = f?.label ?? 'Tất cả';
    final hasFilter = filter != 'all';
    final heading = hasFilter
        ? 'Chưa có giao dịch "$label"'
        : 'Lịch sử trống';
    final description = hasFilter
        ? 'Khi có giao dịch mới ở trạng thái này, nó sẽ xuất hiện ở đây.'
        : 'Nạp tiền lần đầu để bắt đầu giao dịch với ví E-BOX Pay.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 24,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            heading,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
