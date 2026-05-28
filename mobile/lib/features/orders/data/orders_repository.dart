import 'package:dio/dio.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../domain/entities/order_history_item.dart';
import '../domain/repositories/i_orders_repository.dart';

class OrdersRepository implements IOrdersRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<OrderHistoryItem>> getOrders() async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.ordersGetMy);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => _mapOrder(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Lỗi khi tải lịch sử đơn hàng');
    } catch (e) {
      throw AppException('Lỗi khi tải lịch sử đơn hàng: $e');
    }
  }

  OrderHistoryItem _mapOrder(Map<String, dynamic> json) {
    final status = json['status']?.toString().toLowerCase() ?? 'unknown';
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();
    final totalAmount = (json['totalAmount'] as num?)?.toInt() ?? 0;
    final lockerId = json['lockerId']?.toString() ?? '';

    return OrderHistoryItem(
      id: json['id']?.toString() ?? '',
      lockerCode: lockerId,
      title: _titleFromStatus(status),
      location: json['location']?.toString() ?? '',
      status: status,
      createdAt: createdAt,
      amount: totalAmount,
      statusLabel: _statusLabelFromStatus(status),
    );
  }

  String _titleFromStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Đơn hàng hoàn tất';
      case 'pending':
        return 'Đang chờ thanh toán';
      case 'cancelled':
        return 'Đơn hàng bị hủy';
      case 'active':
        return 'Đơn hàng đang thực hiện';
      case 'reserved':
        return 'Đơn hàng đã đặt';
      default:
        return 'Lịch sử truy cập';
    }
  }

  String _statusLabelFromStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn tất';
      case 'pending':
        return 'Chờ thanh toán';
      case 'cancelled':
        return 'Đã hủy';
      case 'active':
        return 'Đang hoạt động';
      case 'reserved':
        return 'Đã đặt';
      default:
        return 'Đang xử lý';
    }
  }
}
