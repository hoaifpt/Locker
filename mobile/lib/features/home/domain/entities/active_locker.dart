/// Pure domain entity — tủ đang được thuê bởi người dùng
class ActiveLocker {
  final String id;
  final String code;
  final String location;
  final String status;
  final double usagePercent;
  final String timeRemaining;

  const ActiveLocker({
    required this.id,
    required this.code,
    required this.location,
    required this.status,
    required this.usagePercent,
    required this.timeRemaining,
  });
}
