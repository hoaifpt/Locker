import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/locker_detail.dart';
import '../domain/repositories/i_locker_detail_repository.dart';
import 'models/locker_detail_model.dart';

class LockerDetailRepository implements ILockerDetailRepository {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/lockers/{id} — trả về chi tiết ngăn tủ
  @override
  Future<LockerDetail> getLockerDetail(String lockerId) async {
    try {
      final response = await _apiClient.client.get('/lockers/$lockerId');
      if (response.statusCode == 200) {
        return LockerDetailModel.fromJson(
            response.data as Map<String, dynamic>);
      }
      throw NetworkException('Không tải được chi tiết tủ');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Lỗi khi tải chi tiết tủ: $e');
    }
  }

  /// POST /api/lockers/{id}/open — mở khóa tủ
  @override
  Future<void> openLocker(String lockerId) async {
    try {
      await _apiClient.client.post(
        '/lockers/$lockerId/open',
        data: {'slotIndex': 0},
      );
    } catch (e) {
      throw NetworkException('Lỗi khi mở tủ: $e');
    }
  }

  /// PATCH /api/lockers/{id}/settings — cập nhật tự động khóa
  @override
  Future<LockerDetail> updateAutoLock(String lockerId,
      {required bool enabled}) async {
    try {
      final response = await _apiClient.client.patch(
        '/lockers/$lockerId/settings',
        data: {'isAutoLockEnabled': enabled},
      );
      return LockerDetailModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw NetworkException('Lỗi khi cập nhật tự động khóa: $e');
    }
  }

  /// PATCH /api/lockers/{id}/settings — cập nhật cảnh báo xâm nhập
  @override
  Future<LockerDetail> updateIntrusionAlert(String lockerId,
      {required bool enabled}) async {
    try {
      final response = await _apiClient.client.patch(
        '/lockers/$lockerId/settings',
        data: {'isIntrusionAlertEnabled': enabled},
      );
      return LockerDetailModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw NetworkException('Lỗi khi cập nhật cảnh báo xâm nhập: $e');
    }
  }
}
