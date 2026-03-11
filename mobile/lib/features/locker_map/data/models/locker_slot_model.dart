import '../../domain/entities/locker_slot.dart';

/// DTO — ánh xạ JSON từ API xuống domain entity LockerSlot
class LockerSlotModel extends LockerSlot {
  const LockerSlotModel({
    required super.id,
    required super.code,
    required super.status,
    super.size,
    super.locationName,
    super.locationAddress,
  });

  factory LockerSlotModel.fromJson(Map<String, dynamic> json) {
    return LockerSlotModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString()),
      size: _parseSize(json['size']?.toString()),
      locationName: json['locationName']?.toString(),
      locationAddress: json['locationAddress']?.toString(),
    );
  }

  static LockerStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'mine':
        return LockerStatus.mine;
      case 'occupied':
        return LockerStatus.occupied;
      default:
        return LockerStatus.available;
    }
  }

  static LockerSize _parseSize(String? raw) =>
      raw == 'large' ? LockerSize.large : LockerSize.normal;

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'status': status.name,
        'size': size.name,
        'locationName': locationName,
        'locationAddress': locationAddress,
      };
}
