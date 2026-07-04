import '../../domain/entities/locker_slot.dart';

class LockerSlotModel extends LockerSlot {
  const LockerSlotModel({
    required super.index,
    required super.status,
    required super.size,
  });

  factory LockerSlotModel.fromJson(Map<String, dynamic> json) {
    return LockerSlotModel(
      index: (json['index'] as num?)?.toInt() ?? -1,
      status: (json['status'] as num?)?.toInt() ?? 1, // Default to occupied
      size: json['size']?.toString() ?? 'Unknown',
    );
  }
}
