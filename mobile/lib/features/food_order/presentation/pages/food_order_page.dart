import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/food_order_repository.dart';
import '../../domain/usecases/get_nearby_restaurants_usecase.dart';
import '../controllers/food_order_cubit.dart';
import '../food_order_screen.dart';

class FoodOrderPage extends StatelessWidget {
  const FoodOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FoodOrderRepository();
    return BlocProvider(
      create: (_) => FoodOrderCubit(
        getNearbyRestaurants: GetNearbyRestaurantsUsecase(repo),
      )..load(),
      child: const FoodOrderScreen(),
    );
  }
}
