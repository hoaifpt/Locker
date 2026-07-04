import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/locker.dart';
import '../domain/repositories/i_locker_repository.dart';
import 'models/locker_model.dart';

class LockerRepository implements ILockerRepository {
  final ApiClient _apiClient = ApiClient();

  /// Lấy danh sách tủ (cần bearer token vì controller có [Authorize])
  @override
  Future<List<Locker>> getLockers() async {
    try {
      final response = await _apiClient.client.get('/lockers');
      if (response.statusCode == 200 && response.data is List) {
        final models = (response.data as List).map(
          (e) => LockerModel.fromJson(e as Map<String, dynamic>),
        );
        return List<Locker>.from(models);
      }
      return [];
    } catch (e) {
      throw NetworkException('Lỗi khi tải danh sách tủ: $e');
    }
  }

  /// Lấy tủ khả dụng (public endpoint: GET /api/lockers/available)
  @override
  Future<List<Locker>> getAvailableLockers() async {
    try {
      final response = await _apiClient.client.get('/lockers/available');
      if (response.statusCode == 200 && response.data is List) {
        final models = (response.data as List).map(
          (e) => LockerModel.fromJson(e as Map<String, dynamic>),
        );
        return List<Locker>.from(models);
      }
      return [];
    } catch (e) {
      throw NetworkException('Lỗi khi tải tủ khả dụng: $e');
    }
  }
}
