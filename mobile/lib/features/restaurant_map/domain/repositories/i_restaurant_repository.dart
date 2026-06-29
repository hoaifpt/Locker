import 'package:locker_mobile/features/restaurant_map/domain/entities/restaurant.dart';

/// {@template i_restaurant_repository}
/// Repository for restaurant data operations.
/// {@endtemplate}
abstract class IRestaurantRepository {
  /// Fetches a list of nearby restaurants based on the user's current location.
  ///
  /// Returns a list of [Restaurant] objects.
  Future<List<Restaurant>> getNearbyRestaurants(
      double latitude, double longitude);
}
