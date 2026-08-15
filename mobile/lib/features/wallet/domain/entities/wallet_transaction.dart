/// Wallet transaction entity. Fields mirror the backend `WalletTransaction`
/// shape with both raw (`status` int, `type` int) and presentation-ready
/// (`title`, `subtitle`, `timeLabel`, `isIncome`) accessors.
///
/// `status` follows `PaymentStatus` int semantics (0..4). `type` matches
/// the web client's transaction type enum — see
/// `web/src/features/wallet/pages/WalletPage.tsx` `TRANSACTION_TYPE_LABELS`.
class WalletTransaction {
  final String id;
  final int amount;
  final int type;
  final int status;

  /// Optional backend `description` field — the human-readable title.
  final String? description;

  /// Optional backend `createdAt` (ISO8601). Used for `timeLabel`
  /// formatting in Vietnamese locale.
  final DateTime? createdAt;

  // Presentation shortcuts (set when constructing from `WalletTransactionModel`
  // for backwards compatibility with older call sites).
  final String title;
  final String subtitle;
  final String timeLabel;
  final bool isIncome;

  const WalletTransaction({
    required this.id,
    required this.amount,
    this.type = 0,
    this.status = 1,
    this.description,
    this.createdAt,
    this.title = '',
    this.subtitle = '',
    this.timeLabel = '',
    this.isIncome = false,
  });

  bool get isCancelled => status == 3;
  bool get isFailed => status == 2;
  bool get isCompleted => status == 1;
  bool get isPending => status == 0;
}
