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
      final response = await _apiClient.client.get(ApiEndpoints.ordersMy);
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
    final dynamic statusValue = json['status'];
    final String status;

    if (statusValue is int) {
      // TODO: This is a temporary workaround. The backend should return a string status.
      // This mapping is based on assumptions and should be verified with the backend team.
      status = _mapIntStatusToString(statusValue);
    } else {
      status = statusValue?.toString().toLowerCase() ?? 'unknown';
    }

    final createdAt =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();
    final totalAmount = (json['totalAmount'] as num?)?.toInt() ?? 0;
    final lockerId = json['lockerId']?.toString() ?? '';

    return OrderHistoryItem(
      id: json['id']?.toString() ?? '',
      lockerCode:
          lockerId, // Backend should provide a shorter, user-friendly code.
      title: _titleFromStatus(status),
      location: json['location']?.toString() ?? 'Không có thông tin vị trí',
      status: status,
      createdAt: createdAt,
      amount: totalAmount,
      statusLabel: _statusLabelFromStatus(status),
    );
  }

  String _mapIntStatusToString(int status) {
    switch (status) {
      case 0:
        return 'pending';
      case 1:
        return 'active';
      case 2:
        return 'completed';
      case 3:
        return 'cancelled';
      case 4:
        return 'reserved';
      case 5: // The provided JSON shows status as 5. Assuming it means 'completed'.
        return 'completed';
      default:
        return 'unknown';
    }
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
