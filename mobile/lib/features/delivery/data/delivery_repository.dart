import '../domain/entities/delivery_package_size.dart';
import '../domain/entities/delivery_request.dart';
import '../domain/repositories/i_delivery_repository.dart';
import 'models/delivery_package_size_model.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

class DeliveryRepository implements IDeliveryRepository {
  final ApiClient _apiClient;

  DeliveryRepository(this._apiClient);

  @override
  Future<List<DeliveryPackageSize>> getPackageSizes() async {
    final response = await _apiClient.client.get('/packages');
    final List<dynamic> data = response.data;
    return data.map((json) => DeliveryPackageSizeModel.fromJson(json)).toList();
  }

  @override
  Future<String> createSendRequest(SendDeliveryRequest request) async {
    try {
      // Map S/M/L sang Small/Medium/Large cho Backend
      final sizeMap = {'S': 'Small', 'M': 'Medium', 'L': 'Large'};
      final mappedSize = sizeMap[request.packageSize] ?? request.packageSize;

      // Thử lần lượt các slot từ 0 đến 5 để tìm slot trống
      for (int slot = 0; slot < 6; slot++) {
        try {
          final response = await _apiClient.client.post(
            '/delivery/requests',
            data: {
              'senderName': request.senderName,
              'receiverPhone': request.receiverPhone,
              'lockerId': request.lockerId,
              'slotIndex': slot,
              'packageSize': mappedSize,
            },
          );
          return response.data['trackingCode'] ??
              'Đã tạo yêu cầu gửi hàng thành công!';
        } catch (e) {
          if (e is DioException && e.response?.statusCode == 400) {
            continue; // Thử slot tiếp theo
          }
          rethrow;
        }
      }
      return 'Tất cả các slot của tủ này hiện đã bị chiếm. Vui lòng chọn tủ khác.';
    } catch (e) {
      if (e is DioException) {
        return 'Lỗi kết nối server: ${e.message}';
      }
      return 'Có lỗi xảy ra: ${e.toString()}';
    }
  }

  @override
  Future<String> submitReceiveCode(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    // Demo: if code contains 'OVERDUE' simulate server response indicating overdue
    if (code.toLowerCase().contains('overdue')) {
      return 'LOCKER_OVERDUE:A-102';
    }

    return 'Đã xác nhận mã nhận hàng: $code';
  }
}
