import '../../domain/entities/delivery_package_size.dart';

class DeliveryPackageSizeModel extends DeliveryPackageSize {
  const DeliveryPackageSizeModel({
    required super.id,
    required super.size,
    required super.price,
    required super.description,
    required super.recommended,
  });

  factory DeliveryPackageSizeModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPackageSizeModel(
      id: json['id']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      price: (json['pricePerHour'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      recommended: json['isActive'] as bool? ?? false,
    );
  }
}
