import '../../domain/entities/locker_size.dart';

class LockerSizeModel extends LockerSize {
  final String imageAsset;

  const LockerSizeModel({
    required super.id,
    required super.size,
    required super.price,
    required super.dimensions,
    super.isRecommended,
    required this.imageAsset,
  });

  factory LockerSizeModel.fromJson(Map<String, dynamic> json) {
    return LockerSizeModel(
      id: json['id'] as String,
      size: json['size'] as String,
      price: json['price'] as int,
      dimensions: json['dimensions'] as String,
      isRecommended: json['isRecommended'] as bool? ?? false,
      imageAsset: json['imageAsset'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size': size,
      'price': price,
      'dimensions': dimensions,
      'isRecommended': isRecommended,
      'imageAsset': imageAsset,
    };
  }
}
