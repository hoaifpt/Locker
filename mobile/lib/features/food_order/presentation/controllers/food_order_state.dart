import 'package:locker_mobile/features/restaurant_map/domain/entities/restaurant.dart';
import 'package:locker_mobile/features/food_order/domain/entities/restaurant_pin.dart';

class FoodOrderState {
  final bool isLoading;
  final List<Restaurant> restaurants;
  final List<RestaurantPin> pins;
  final String? selectedRestaurantId;

  const FoodOrderState({
    required this.isLoading,
    required this.restaurants,
    required this.pins,
    required this.selectedRestaurantId,
  });

  factory FoodOrderState.initial() {
    return const FoodOrderState(
      isLoading: true,
      restaurants: [],
      pins: [],
      selectedRestaurantId: null,
    );
  }

  FoodOrderState copyWith({
    bool? isLoading,
    List<Restaurant>? restaurants,
    List<RestaurantPin>? pins,
    String? selectedRestaurantId,
    bool clearSelection = false,
  }) {
    return FoodOrderState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      pins: pins ?? this.pins,
      selectedRestaurantId: clearSelection
          ? null
          : (selectedRestaurantId ?? this.selectedRestaurantId),
    );
  }

  Restaurant? get selectedRestaurant {
    if (selectedRestaurantId == null || restaurants.isEmpty) {
      return null;
    }
    try {
      return restaurants.firstWhere((item) => item.id == selectedRestaurantId);
    } catch (e) {
      return null;
    }
  }

  RestaurantPin? get selectedPin {
    if (selectedRestaurantId == null || pins.isEmpty) {
      return null;
    }
    try {
      return pins.firstWhere((item) => item.id == selectedRestaurantId);
    } catch (e) {
      return null;
    }
  }
}
