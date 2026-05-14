import '../domain/entities/restaurant_pin.dart';
import '../domain/repositories/i_food_order_repository.dart';
import 'models/restaurant_pin_model.dart';

class FoodOrderRepository implements IFoodOrderRepository {
  @override
  Future<List<RestaurantPin>> getNearbyRestaurants() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const [
      RestaurantPinModel(
        id: 'res-1',
        name: 'Hoi An Eatery',
        rating: 4.8,
        distanceKm: 0.4,
        offsetX: 0.54,
        offsetY: 0.50,
        isOpen: true,
        tags: ['PHỞ BÒ', 'BÁNH MÌ', 'CÀ PHÊ', 'BÚN CHẢ'],
        imageUrl: 'https://placehold.co/80x80',
      ),
      RestaurantPinModel(
        id: 'res-2',
        name: 'Pho Saigon Corner',
        rating: 4.6,
        distanceKm: 0.8,
        offsetX: 0.33,
        offsetY: 0.38,
        isOpen: true,
        tags: ['PHỞ', 'CƠM TẤM'],
        imageUrl: 'https://placehold.co/80x80',
      ),
      RestaurantPinModel(
        id: 'res-3',
        name: 'Morning Bun Cha',
        rating: 4.7,
        distanceKm: 1.2,
        offsetX: 0.28,
        offsetY: 0.63,
        isOpen: false,
        tags: ['BÚN CHẢ', 'NEM'],
        imageUrl: 'https://placehold.co/80x80',
      ),
    ];
  }
}
