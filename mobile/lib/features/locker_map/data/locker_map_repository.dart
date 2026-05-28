import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/locker_slot.dart';
import '../domain/repositories/i_locker_map_repository.dart';
import 'models/locker_slot_model.dart';

class LockerMapRepository implements ILockerMapRepository {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/lockers/map — trả về danh sách tất cả slot kèm trạng thái
  @override
  Future<List<LockerSlot>> getLockerSlots() async {
    try {
      final response = await _apiClient.client.get('/lockers/map');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => LockerSlotModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw NetworkException('Lỗi khi tải sơ đồ tủ: $e');
    }
  }

  /// POST /api/lockers/{id}/open — mở tủ đã chọn
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
}
