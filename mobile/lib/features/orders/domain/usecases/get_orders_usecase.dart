import '../entities/order_history_item.dart';
import '../repositories/i_orders_repository.dart';

class GetOrdersUsecase {
  final IOrdersRepository repository;

  GetOrdersUsecase({required this.repository});

  Future<List<OrderHistoryItem>> call() {
    return repository.getOrders();
  }
}
