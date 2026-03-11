import '../../domain/entities/locker_activity.dart';

/// DTO — ánh xạ JSON từ API xuống domain entity LockerActivity
class LockerActivityModel extends LockerActivity {
  const LockerActivityModel({
    required super.id,
    required super.action,
    required super.timestamp,
    super.isRecent,
  });

  factory LockerActivityModel.fromJson(Map<String, dynamic> json) {
    return LockerActivityModel(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      isRecent: json['isRecent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'timestamp': timestamp.toIso8601String(),
        'isRecent': isRecent,
      };
}
