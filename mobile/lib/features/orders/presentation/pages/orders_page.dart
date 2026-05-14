import 'package:flutter/material.dart';

import '../../data/orders_repository.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'orders_screen.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = OrdersRepository();
    return OrdersScreen(
      getOrders: GetOrdersUsecase(repository: repository),
    );
  }
}
