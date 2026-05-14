class OrderHistoryItem {
  final String id;
  final String lockerCode;
  final String title;
  final String location;
  final String status;
  final DateTime createdAt;
  final int amount;
  final String statusLabel;

  const OrderHistoryItem({
    required this.id,
    required this.lockerCode,
    required this.title,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.amount,
    required this.statusLabel,
  });
}
