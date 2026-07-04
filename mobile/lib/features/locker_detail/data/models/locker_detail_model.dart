import '../../domain/entities/locker_detail.dart';
import 'locker_activity_model.dart';

/// DTO — ánh xạ JSON từ API xuống domain entity LockerDetail
class LockerDetailModel extends LockerDetail {
  const LockerDetailModel({
    required super.id,
    required super.code,
    required super.doorStatus,
    required super.batteryPercent,
    required super.remainingHours,
    required super.isAutoLockEnabled,
    required super.isIntrusionAlertEnabled,
    super.imageUrl,
    super.recentActivities,
  });

  factory LockerDetailModel.fromJson(Map<String, dynamic> json) {
    return LockerDetailModel(
      id: json['id']?.toString() ?? '',
      code: json['name']?.toString() ?? json['code']?.toString() ?? '',
      doorStatus: json['doorStatus']?.toString() == 'open'
          ? LockerDoorStatus.open
          : LockerDoorStatus.closed,
      batteryPercent: (json['batteryPercent'] as num?)?.toInt() ?? 75,
      remainingHours: (json['remainingHours'] as num?)?.toInt() ?? 24,
      isAutoLockEnabled: json['isAutoLockEnabled'] as bool? ?? false,
      isIntrusionAlertEnabled:
          json['isIntrusionAlertEnabled'] as bool? ?? false,
      imageUrl: json['imageUrl']?.toString(),
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.map((e) =>
                  LockerActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'doorStatus': doorStatus.name,
        'batteryPercent': batteryPercent,
        'remainingHours': remainingHours,
        'isAutoLockEnabled': isAutoLockEnabled,
        'isIntrusionAlertEnabled': isIntrusionAlertEnabled,
        'imageUrl': imageUrl,
        'recentActivities': recentActivities
            .map((a) => {
                  'id': a.id,
                  'action': a.action,
                  'timestamp': a.timestamp.toIso8601String(),
                  'isRecent': a.isRecent,
                })
            .toList(),
      };
}
