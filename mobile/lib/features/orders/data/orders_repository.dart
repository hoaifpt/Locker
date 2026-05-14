import '../domain/entities/order_history_item.dart';
import '../domain/repositories/i_orders_repository.dart';

class OrdersRepository implements IOrdersRepository {
  @override
  Future<List<OrderHistoryItem>> getOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return [
      OrderHistoryItem(
        id: 'ORD-1024',
        lockerCode: 'Locker A-12',
        title: 'Mở tủ thành công',
        location: 'Main Hall Entrance',
        status: 'completed',
        createdAt: DateTime(2023, 10, 24, 16, 32),
        amount: 17000,
        statusLabel: 'Hoàn tất',
      ),
      OrderHistoryItem(
        id: 'ORD-1025',
        lockerCode: 'Locker B-04',
        title: 'Đang chờ thanh toán',
        location: 'North Wing Station',
        status: 'pending',
        createdAt: DateTime(2023, 10, 23, 9, 12),
        amount: 25000,
        statusLabel: 'Chờ thanh toán',
      ),
      OrderHistoryItem(
        id: 'ORD-1026',
        lockerCode: 'Locker C-08',
        title: 'Đơn đã hủy',
        location: 'Basement Hub',
        status: 'cancelled',
        createdAt: DateTime(2023, 10, 22, 14, 5),
        amount: 0,
        statusLabel: 'Đã hủy',
      ),
    ];
  }
}
