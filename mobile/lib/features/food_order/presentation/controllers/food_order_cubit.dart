import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locker_mobile/features/food_order/domain/entities/restaurant_pin.dart';
import 'package:locker_mobile/features/restaurant_map/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'food_order_state.dart';

class FoodOrderCubit extends Cubit<FoodOrderState> {
  final GetNearbyRestaurants _getNearbyRestaurants;

  FoodOrderCubit({required GetNearbyRestaurants getNearbyRestaurants})
    : _getNearbyRestaurants = getNearbyRestaurants,
      super(FoodOrderState.initial());

  Future<void> load() async {
    // 1. Đặt isLoading = true
    emit(state.copyWith(isLoading: true));

    // 2. Lấy danh sách nhà hàng từ usecase (tọa độ giả định)
    // TODO: Thay thế bằng vị trí thực của người dùng
    final restaurants = await _getNearbyRestaurants(10.8231, 106.6297);

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
    emit(
      state.copyWith(
        isLoading: false,
        restaurants: restaurants,
        pins: pins,
        selectedRestaurantId: null,
      ),
    );
  }

  void selectRestaurant(String id) {
    emit(state.copyWith(selectedRestaurantId: id));
  }

  /// Xóa nhà hàng đang được chọn, dùng để ẩn BottomSheet
  void clearSelection() {
    emit(state.copyWith(clearSelection: true));
  }
}
