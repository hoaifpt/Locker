import '../../domain/entities/restaurant_pin.dart';

class RestaurantPinModel extends RestaurantPin {
  const RestaurantPinModel({
    required super.id,
    required super.name,
    required super.rating,
    required super.distanceKm,
    required super.offsetX,
    required super.offsetY,
    required super.isOpen,
    required super.tags,
    required super.imageUrl,
    required super.description,
    required super.address,
  });
}
