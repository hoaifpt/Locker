class LockerModel {
  final String id;
  final String code;
  final bool isOccupied;
  final String location;
  final double latitude;
  final double longitude;

  LockerModel({
    required this.id,
    required this.code,
    required this.isOccupied,
    this.location = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory LockerModel.fromJson(Map<String, dynamic> json) {
    return LockerModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'Unknown',
      isOccupied: json['isOccupied'] ?? false,
      location: json['location']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
