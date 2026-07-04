import 'package:locker_mobile/features/restaurant_map/data/models/restaurant_model.dart';
import 'package:locker_mobile/features/restaurant_map/domain/entities/restaurant.dart';
import 'package:locker_mobile/features/restaurant_map/domain/repositories/i_restaurant_repository.dart';
import 'package:locker_mobile/core/constants/api_endpoints.dart';
import 'package:locker_mobile/core/network/api_client.dart';
import 'dart:developer';

/// {@template restaurant_repository}
/// Repository implementation for fetching nearby restaurants from the backend.
/// {@endtemplate}
class RestaurantRepository implements IRestaurantRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<Restaurant>> getNearbyRestaurants(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.restaurants);

      log('[Repo] Status: ${response.statusCode}');
      log('[Repo] Data type: ${response.data.runtimeType}');
      log('[Repo] Raw data: ${response.data}');

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        log('[Repo] API returned ${data.length} items');

        final models = data
            .map((json) => RestaurantModel.fromJson(json))
            .toList();

        // Ánh xạ từ Data Model sang Domain Entity thay vì ép kiểu không an toàn
        final restaurants = models.map((model) {
          final lat = model.location.coordinates.lat.toDouble();
          final lng = model.location.coordinates.lng.toDouble();
          log('[Repo] Restaurant: ${model.name} - lat: $lat, lng: $lng');

          return Restaurant(
            id: model.id,
            name: model.name,
            description: model.description,
            address: model.address,
            imageUrl: model.imageUrl,
            rating: model.rating,
            longitude: lng,
            latitude: lat,
            distanceKm: 0.0, // Giá trị mặc định, sẽ được tính toán sau
            isOpen: true, // Giá trị mặc định
          );
        }).toList();

        log('[Repo] Returning ${restaurants.length} restaurants');
        return restaurants;
      } else {
        log('[Repo] Unexpected response: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      log('[Repo] Error: $e', stackTrace: stackTrace);
      return [];
    }
  }
}
