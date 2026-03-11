import 'locker_activity.dart';

/// Trạng thái vật lý của cửa tủ
enum LockerDoorStatus { open, closed }

/// Chi tiết đầy đủ của một ngăn tủ — pure domain entity
class LockerDetail {
  final String id;
  final String code;
  final LockerDoorStatus doorStatus;
  final int batteryPercent;
  final int remainingHours;
  final bool isAutoLockEnabled;
  final bool isIntrusionAlertEnabled;
  final String? imageUrl;
  final List<LockerActivity> recentActivities;

  const LockerDetail({
    required this.id,
    required this.code,
    required this.doorStatus,
    required this.batteryPercent,
    required this.remainingHours,
    required this.isAutoLockEnabled,
    required this.isIntrusionAlertEnabled,
    this.imageUrl,
    this.recentActivities = const [],
  });

  LockerDetail copyWith({
    LockerDoorStatus? doorStatus,
    int? batteryPercent,
    int? remainingHours,
    bool? isAutoLockEnabled,
    bool? isIntrusionAlertEnabled,
    String? imageUrl,
    List<LockerActivity>? recentActivities,
  }) {
    return LockerDetail(
      id: id,
      code: code,
      doorStatus: doorStatus ?? this.doorStatus,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      remainingHours: remainingHours ?? this.remainingHours,
      isAutoLockEnabled: isAutoLockEnabled ?? this.isAutoLockEnabled,
      isIntrusionAlertEnabled:
          isIntrusionAlertEnabled ?? this.isIntrusionAlertEnabled,
      imageUrl: imageUrl ?? this.imageUrl,
      recentActivities: recentActivities ?? this.recentActivities,
    );
  }
}
