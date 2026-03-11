import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../locker/data/models/locker_model.dart';
import '../../locker/domain/entities/locker.dart';
import '../domain/entities/active_locker.dart';
import '../domain/repositories/i_home_repository.dart';
import 'models/active_locker_model.dart';

class HomeRepository implements IHomeRepository {
  final ApiClient _apiClient = ApiClient();

  /// Tủ đang thuê của user (cần bearer token)
  @override
  Future<List<ActiveLocker>> getActiveLockers() async {
    try {
      final response = await _apiClient.client
          .get('/bookings/my', queryParameters: {'status': 'Active'});
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => ActiveLockerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw NetworkException('Lỗi khi tải tủ đang dùng: $e');
    }
  }

  /// Tủ khả dụng gần đây (public endpoint)
  @override
  Future<List<Locker>> getNearbyLockers() async {
    try {
      final response = await _apiClient.client.get('/lockers/available');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => LockerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw NetworkException('Lỗi khi tải tủ gần đây: $e');
    }
  }
}
