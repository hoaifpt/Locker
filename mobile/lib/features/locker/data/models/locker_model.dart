import '../../domain/entities/locker.dart';

/// DTO mapping giữa JSON từ API backend và domain entity Locker
class LockerModel extends Locker {
  const LockerModel({
    required super.id,
    required super.code,
    required super.isOccupied,
    super.location,
  });

  factory LockerModel.fromJson(Map<String, dynamic> json) {
    return LockerModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'Unknown',
      isOccupied: json['isOccupied'] ?? false,
      location: json['location']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'isOccupied': isOccupied,
        'location': location,
      };
}
