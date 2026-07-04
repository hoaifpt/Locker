import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/locker_size.dart';
import '../domain/entities/send_receive_order.dart';
import '../domain/entities/storage_duration.dart';
import '../domain/repositories/i_send_receive_repository.dart';
import 'models/locker_size_model.dart';
import 'models/send_receive_order_model.dart';
import 'models/storage_duration_model.dart';

class SendReceiveRepository implements ISendReceiveRepository {
  final ApiClient _apiClient = ApiClient();

  static const _storageDurations = <StorageDurationModel>[
    StorageDurationModel(
      id: 'duration-1h',
      label: '1 Giờ',
      durationHours: 1,
      isRecommended: false,
    ),
    StorageDurationModel(
      id: 'duration-4h',
      label: '4 Giờ',
      durationHours: 4,
      isRecommended: true,
    ),
    StorageDurationModel(
      id: 'duration-full-day',
      label: 'Trong ngày',
      durationHours: 24,
      isRecommended: false,
    ),
    StorageDurationModel(
      id: 'duration-long-term',
      label: 'Gửi lâu dài',
      durationHours: 720, // 30 days
      isRecommended: false,
    ),
  ];

  @override
  Future<List<LockerSize>> getAvailableLockerSizes() async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.packages);
      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((e) => LockerSizeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw NetworkException('Không nhận được dữ liệu kích thước tủ.');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] is String) {
        throw ValidationException(e.response!.data['message']);
      }
      throw NetworkException('Lỗi khi tải kích thước tủ: ${e.message}');
    } catch (e) {
      throw AppException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  @override
  Future<List<StorageDuration>> getStorageDurations() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _storageDurations;
  }

  @override
  Future<Map<String, dynamic>> createSendReceiveOrder({
    required String lockerId,
    required int slotIndex,
    required String packageId,
    required int durationHours,
    required String mobileNumber,
    required DateTime checkInTime,
    String? couponCode,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.ordersReserve,
        data: {
          'lockerId': lockerId,
          'slotIndex': slotIndex,
          'packageId': packageId,
          'durationHours': durationHours,
          'mobileNumber': mobileNumber,
          'checkInTime': checkInTime.toUtc().toIso8601String(),
          'couponCode': couponCode,
          'notes': notes,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Xử lý lỗi validation từ ASP.NET Core một cách chi tiết
      if (e.response?.statusCode == 400 && e.response?.data is Map) {
        final responseData = e.response!.data as Map<String, dynamic>;
        final title = responseData['title'] as String? ?? 'Lỗi validation';
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          // Lấy thông báo lỗi của trường đầu tiên
          final firstErrorField = errors.values.first as List<dynamic>;
          throw ValidationException('$title: ${firstErrorField.first}');
        }
      }
      throw NetworkException('Lỗi mạng khi tạo đơn hàng: ${e.message}');
    } catch (e) {
      throw AppException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  @override
  Future<SendReceiveOrder> getOrderById(String orderId) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.orderById(orderId),
      );
      if (response.data != null) {
        return SendReceiveOrderModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw NetworkException('Không nhận được dữ liệu đơn hàng.');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] is String) {
        throw ValidationException(e.response!.data['message']);
      }
      throw NetworkException('Lỗi khi tải thông tin đơn hàng: ${e.message}');
    } catch (e) {
      throw AppException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  @override
  Future<void> confirmOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
