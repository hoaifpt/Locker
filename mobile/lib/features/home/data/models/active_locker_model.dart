import '../../domain/entities/active_locker.dart';

/// DTO mapping giữa JSON từ API backend (BookingDto) và domain entity ActiveLocker
class ActiveLockerModel extends ActiveLocker {
  const ActiveLockerModel({
    required super.id,
    required super.code,
    required super.location,
    required super.status,
    required super.usagePercent,
    required super.timeRemaining,
  });

  factory ActiveLockerModel.fromJson(Map<String, dynamic> json) {
    // BookingDto fields: id, lockerId, slotIndex, status, startedAt, completedAt
    final lockerId = json['lockerId']?.toString() ?? '';
    final slotIndex = json['slotIndex']?.toString() ?? '0';
    final status = json['status']?.toString() ?? 'Active';

    // Tính thời gian còn lại từ completedAt nếu có
    String timeRemaining = '';
    final completedAtStr = json['completedAt']?.toString();
    if (completedAtStr != null) {
      try {
        final end = DateTime.parse(completedAtStr);
        final diff = end.difference(DateTime.now());
        if (diff.isNegative) {
          timeRemaining = 'Hết hạn';
        } else {
          final h = diff.inHours;
          final m = diff.inMinutes % 60;
          timeRemaining =
              '${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m';
        }
      } catch (_) {}
    }

    return ActiveLockerModel(
      id: json['id']?.toString() ?? '',
      code:
          'Ô $slotIndex - ${lockerId.length > 8 ? lockerId.substring(0, 8) : lockerId}',
      location: '',
      status: status.toUpperCase(),
      usagePercent: 0.0,
      timeRemaining: timeRemaining,
    );
  }
}
