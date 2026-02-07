class LockerModel {
  final String id;
  final String code;
  final bool isOccupied;
  final String location;

  LockerModel({
    required this.id,
    required this.code,
    required this.isOccupied,
    this.location = '',
  });

  factory LockerModel.fromJson(Map<String, dynamic> json) {
    return LockerModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'Unknown',
      isOccupied: json['isOccupied'] ?? false,
      location: json['location']?.toString() ?? '',
    );
  }
}
