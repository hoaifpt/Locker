import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_nearby_restaurants_usecase.dart';
import 'food_order_state.dart';

class FoodOrderCubit extends Cubit<FoodOrderState> {
  final GetNearbyRestaurantsUsecase _getNearbyRestaurants;

  FoodOrderCubit({required GetNearbyRestaurantsUsecase getNearbyRestaurants})
      : _getNearbyRestaurants = getNearbyRestaurants,
        super(FoodOrderState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final restaurants = await _getNearbyRestaurants();
    emit(state.copyWith(
      isLoading: false,
      restaurants: restaurants,
      selectedRestaurantId: restaurants.isEmpty ? null : restaurants.first.id,
    ));
  }

  void selectRestaurant(String id) {
    emit(state.copyWith(selectedRestaurantId: id));
  }
}
