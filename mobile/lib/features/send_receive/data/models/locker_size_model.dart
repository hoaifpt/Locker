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
      id: json['id']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      price: (json['pricePerHour'] as num?)?.toInt() ?? 0,
      dimensions: json['dimensions']?.toString() ?? 'N/A',
      // API trả về 'isActive', ta ánh xạ nó sang 'isRecommended'.
      isRecommended: json['isActive'] as bool? ?? false,
      // API không trả về 'imageAsset'. Cung cấp một giá trị tạm thời.
      imageAsset:
          'assets/images/locker_default.png', // TODO: Cập nhật lại đường dẫn ảnh thực tế
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
