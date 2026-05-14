import '../entities/restaurant_pin.dart';

abstract class IFoodOrderRepository {
  Future<List<RestaurantPin>> getNearbyRestaurants();
}
