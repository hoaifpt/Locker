import 'package:locker_mobile/features/restaurant_map/domain/entities/restaurant.dart';
import 'package:locker_mobile/features/food_order/domain/entities/restaurant_pin.dart';

class FoodOrderState {
  final bool isLoading;
  final List<Restaurant> restaurants;
  final List<RestaurantPin> pins;
  final String? selectedRestaurantId;
  final String searchQuery;
  final List<Restaurant> searchResults;

  const FoodOrderState({
    required this.isLoading,
    required this.restaurants,
    required this.pins,
    required this.selectedRestaurantId,
    required this.searchQuery,
    required this.searchResults,
  });

  factory FoodOrderState.initial() {
    return const FoodOrderState(
      isLoading: true,
      restaurants: [],
      pins: [],
      selectedRestaurantId: null,
      searchQuery: '',
      searchResults: [],
    );
  }

  FoodOrderState copyWith({
    bool? isLoading,
    List<Restaurant>? restaurants,
    List<RestaurantPin>? pins,
    String? selectedRestaurantId,
    bool clearSelection = false,
    String? searchQuery,
    List<Restaurant>? searchResults,
  }) {
    return FoodOrderState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      pins: pins ?? this.pins,
      selectedRestaurantId: clearSelection
          ? null
          : (selectedRestaurantId ?? this.selectedRestaurantId),
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
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
