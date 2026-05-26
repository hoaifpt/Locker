class NotificationEntity {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final String iconType; // 'success', 'warning', 'info'
  final String category; // 'MỚI NHẤT', 'TRƯỚC ĐÓ'
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.iconType,
    required this.category,
    required this.isRead,
  });
}
