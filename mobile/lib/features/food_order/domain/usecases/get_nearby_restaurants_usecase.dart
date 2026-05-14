import '../entities/restaurant_pin.dart';
import '../repositories/i_food_order_repository.dart';

class GetNearbyRestaurantsUsecase {
  final IFoodOrderRepository _repository;

  GetNearbyRestaurantsUsecase(this._repository);

  Future<List<RestaurantPin>> call() {
    return _repository.getNearbyRestaurants();
  }
}
