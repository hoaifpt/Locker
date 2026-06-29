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
        final models = data
            .map((json) => RestaurantModel.fromJson(json))
            .toList();

        // Ánh xạ từ Data Model sang Domain Entity thay vì ép kiểu không an toàn
        return models.map((model) {
          return Restaurant(
            id: model.id,
            name: model.name,
            description: model.description,
            address: model.address,
            imageUrl: model.imageUrl,
            rating: model.rating,
            longitude: model.location.coordinates.lng.toDouble(),
            latitude: model.location.coordinates.lat.toDouble(),
            distanceKm: 0.0, // Giá trị mặc định, sẽ được tính toán sau
            isOpen: true, // Giá trị mặc định
          );
        }).toList();
      } else {
        // If the response is not as expected, return an empty list or throw an exception
        return [];
      }
    } catch (e) {
      // In case of any error, return an empty list or rethrow
      return [];
    }
  }
}
