import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String imageUrl;
  final double rating;
  final Point location; // Sử dụng kiểu Point của Mapbox

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.location,
  });

  // Logic quan trọng: Ép kiểu tọa độ từ JSON sang Point của Mapbox
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    // ✅ API trả về latitude/longitude trực tiếp
    final double longitude = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final double latitude = (json['latitude'] as num?)?.toDouble() ?? 0.0;

    return RestaurantModel(
      id: json['id']?.toString() ?? '', // ✅ API dùng 'id' không phải '_id'
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      location: Point(coordinates: Position(longitude, latitude)),
    );
  }
}
