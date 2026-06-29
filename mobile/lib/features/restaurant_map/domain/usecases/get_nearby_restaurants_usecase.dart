import 'package:locker_mobile/features/restaurant_map/domain/entities/restaurant.dart';
import 'package:locker_mobile/features/restaurant_map/domain/repositories/i_restaurant_repository.dart';

/// {@template get_nearby_restaurants_usecase}
/// Use case for fetching nearby restaurants.
/// {@endtemplate}
class GetNearbyRestaurants {
  /// {@macro get_nearby_restaurants_usecase}
  const GetNearbyRestaurants(this._repository);

  final IRestaurantRepository _repository;

  /// Executes the use case and returns a list of nearby restaurants.
  ///
  /// [latitude] and [longitude] are the user's current coordinates.
  Future<List<Restaurant>> call(double latitude, double longitude) {
    return _repository.getNearbyRestaurants(latitude, longitude);
  }
}
