import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locker_mobile/features/restaurant_map/data/restaurant_repository.dart';
import 'package:locker_mobile/features/restaurant_map/domain/usecases/get_nearby_restaurants_usecase.dart';

import '../controllers/food_order_cubit.dart';
import '../food_order_screen.dart';

class FoodOrderPage extends StatelessWidget {
  const FoodOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RestaurantRepository();
    return BlocProvider(
      create: (_) => FoodOrderCubit(
        getNearbyRestaurants: GetNearbyRestaurants(repo),
      )..load(),
      child: const FoodOrderScreen(),
    );
  }
}
