class WalletTransaction {
  final String id;
  final String title;
  final String subtitle;
  final int amount;
  final String timeLabel;
  final bool isIncome;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.timeLabel,
    required this.isIncome,
  });
}
