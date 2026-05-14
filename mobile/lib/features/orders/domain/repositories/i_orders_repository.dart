import '../entities/order_history_item.dart';

abstract class IOrdersRepository {
  Future<List<OrderHistoryItem>> getOrders();
}
