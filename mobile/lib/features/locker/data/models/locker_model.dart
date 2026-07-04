import '../../domain/entities/locker.dart';
import 'locker_slot_model.dart';

/// DTO mapping giữa JSON từ API backend và domain entity Locker
class LockerModel extends Locker {
  const LockerModel({
    required super.id,
    required super.name,
    super.location,
    required List<LockerSlotModel> super.slots,
  });

  factory LockerModel.fromJson(Map<String, dynamic> json) {
    return LockerModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Locker',
      location: json['location']?.toString() ?? '',
      slots:
          (json['slots'] as List<dynamic>?)
              ?.map((e) => LockerSlotModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'slots': slots.map((s) => (s as LockerSlotModel)).toList(),
  };
}
