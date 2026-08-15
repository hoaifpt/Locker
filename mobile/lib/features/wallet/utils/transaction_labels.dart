/// Localised transaction type & status labels. Mirrors
/// `web/src/features/wallet/pages/WalletPage.tsx`
/// `TRANSACTION_TYPE_LABELS` / `TRANSACTION_STATUS_LABELS` /
/// `TRANSACTION_STATUS_FILTERS`.
library;

const Map<int, String> kTransactionTypeLabels = {
  0: 'Nạp tiền',
  1: 'Thanh toán',
  2: 'Hoàn tiền',
  3: 'Rút tiền',
};

/// `PaymentStatus` int → Vietnamese label (see
/// `lib/features/wallet/domain/entities/payment_status.dart`).
/// 0=pending, 1=completed, 2=failed, 3=cancelled, 4=expired.
const Map<int, String> kTransactionStatusLabels = {
  0: 'Đang xử lý',
  1: 'Hoàn thành',
  2: 'Thất bại',
  3: 'Đã huỷ',
  4: 'Hết hạn',
};

String transactionTypeLabel(int type) =>
    kTransactionTypeLabels[type] ?? 'Giao dịch';

String transactionStatusLabel(int status) =>
    kTransactionStatusLabels[status] ?? 'Không xác định';

class StatusFilterChip {
  final String value;
  final String label;
  const StatusFilterChip({required this.value, required this.label});
}

/// Status filter tabs for the transaction history section. The `value`
/// matches a status int or the sentinel `'all'`. Mirrors
/// `TRANSACTION_STATUS_FILTERS` on web.
const List<StatusFilterChip> kTransactionStatusFilters = [
  StatusFilterChip(value: 'all', label: 'Tất cả'),
  StatusFilterChip(value: '1', label: 'Hoàn thành'),
  StatusFilterChip(value: '0', label: 'Đang xử lý'),
  StatusFilterChip(value: '3', label: 'Đã huỷ'),
  StatusFilterChip(value: '2', label: 'Thất bại'),
];
