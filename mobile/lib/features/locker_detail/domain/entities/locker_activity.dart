/// Một sự kiện trong lịch sử hoạt động của tủ
class LockerActivity {
  final String id;
  final String action; // VD: "Đã mở khóa", "Đã khóa tự động"
  final DateTime timestamp;
  final bool isRecent; // true = dot cam (sự kiện gần nhất), false = dot xám

  const LockerActivity({
    required this.id,
    required this.action,
    required this.timestamp,
    this.isRecent = false,
  });
}
