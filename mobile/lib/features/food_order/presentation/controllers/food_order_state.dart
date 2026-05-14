import '../../domain/entities/restaurant_pin.dart';

class FoodOrderState {
  final bool isLoading;
  final List<RestaurantPin> restaurants;
  final String? selectedRestaurantId;

  const FoodOrderState({
    required this.isLoading,
    required this.restaurants,
    required this.selectedRestaurantId,
  });

  factory FoodOrderState.initial() {
    return const FoodOrderState(
      isLoading: true,
      restaurants: [],
      selectedRestaurantId: null,
    );
  }

  FoodOrderState copyWith({
    bool? isLoading,
    List<RestaurantPin>? restaurants,
    String? selectedRestaurantId,
    bool clearSelection = false,
  }) {
    return FoodOrderState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      selectedRestaurantId: clearSelection
          ? null
          : (selectedRestaurantId ?? this.selectedRestaurantId),
    );
  }

  RestaurantPin? get selectedRestaurant {
    if (selectedRestaurantId == null) {
      return restaurants.isEmpty ? null : restaurants.first;
    }
    for (final item in restaurants) {
      if (item.id == selectedRestaurantId) return item;
    }
    return restaurants.isEmpty ? null : restaurants.first;
  }
}
