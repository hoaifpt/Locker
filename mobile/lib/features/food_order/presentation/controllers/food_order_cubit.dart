import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locker_mobile/features/food_order/domain/entities/restaurant_pin.dart';
import 'package:locker_mobile/features/restaurant_map/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'dart:developer';
import 'food_order_state.dart';

class FoodOrderCubit extends Cubit<FoodOrderState> {
  final GetNearbyRestaurants _getNearbyRestaurants;

  FoodOrderCubit({required GetNearbyRestaurants getNearbyRestaurants})
    : _getNearbyRestaurants = getNearbyRestaurants,
      super(FoodOrderState.initial());

  Future<void> load() async {
    log('[Cubit] Starting load()');
    // 1. Đặt isLoading = true
    emit(state.copyWith(isLoading: true));

    // 2. Lấy danh sách nhà hàng từ usecase (tọa độ giả định)
    // TODO: Thay thế bằng vị trí thực của người dùng
    log('[Cubit] Calling GetNearbyRestaurants with coords (10.8231, 106.6297)');
    final restaurants = await _getNearbyRestaurants(10.8231, 106.6297);

    log('[Cubit] Received ${restaurants.length} restaurants from usecase');
    for (var r in restaurants) {
      log(
        '[Cubit] Restaurant: ${r.name} - lat: ${r.latitude}, lng: ${r.longitude}',
      );
    }

    // 3. Chuyển đổi từ Restaurant sang RestaurantPin
    final pins = restaurants.map((restaurant) {
      return RestaurantPin(
        id: restaurant.id,
        name: restaurant.name,
        rating: restaurant.rating,
        distanceKm: restaurant.distanceKm,
        isOpen: restaurant.isOpen,
        imageUrl: restaurant.imageUrl,
        tags: [],
        address: restaurant.address,
        description: restaurant.description,
        offsetX: 0.0, // Không cần thiết khi dùng Mapbox annotation thật
        offsetY: 0.0, // Giả định dải vĩ độ
      );
    }).toList();

    // 4. Phát ra state mới với cả danh sách gốc và danh sách pin
    final newState = state.copyWith(
      isLoading: false,
      restaurants: restaurants,
      pins: pins,
      selectedRestaurantId: null,
    );

    log(
      '[Cubit] Emitting new state with ${newState.restaurants.length} restaurants',
    );
    emit(newState);
    log('[Cubit] State emitted successfully');
  }

  void search(String query) {
    log('[Cubit] search("$query")');
    if (query.isEmpty) {
      emit(state.copyWith(searchQuery: '', searchResults: []));
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    final results = state.restaurants.where((restaurant) {
      final nameMatch = restaurant.name.toLowerCase().contains(lowerCaseQuery);
      final addressMatch =
          restaurant.address.toLowerCase().contains(lowerCaseQuery);
      // As per current data structure, tags are not available on the Restaurant entity for searching.
      return nameMatch || addressMatch;
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      searchResults: results,
    ));
  }

  void selectRestaurant(String id) {
    log('[Cubit] selectRestaurant($id)');
    // When a restaurant is selected, clear the search query and results to hide the suggestion list.
    // The search text field will be updated by the UI listener.
    emit(state.copyWith(
      selectedRestaurantId: id,
      searchQuery: '',
      searchResults: [],
    ));
  }

  /// Xóa nhà hàng đang được chọn, dùng để ẩn BottomSheet
  void clearSelection() {
    log('[Cubit] clearSelection()');
    // Also clear search when clearing selection (e.g., user taps map background)
    emit(state.copyWith(clearSelection: true, searchQuery: '', searchResults: []));
  }
}
