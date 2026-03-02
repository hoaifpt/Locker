<<<<<<< HEAD
=======
import 'package:dio/dio.dart';
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
import '../../../core/network/api_client.dart';
import '../models/locker_model.dart';

class LockerRepository {
  final ApiClient _apiClient = ApiClient();

  // Lấy danh sách tủ
  Future<List<LockerModel>> getLockers() async {
    try {
      final response = await _apiClient.client.get('/lockers');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => LockerModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      // Xử lý lỗi hoặc ném tiếp ra ngoài
      throw Exception('Lỗi khi tải danh sách tủ: $e');
    }
  }

  // Mở tủ
  Future<bool> openLocker(String id) async {
    try {
      final response = await _apiClient.client.post('/lockers/$id/open');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Không thể mở tủ: $e');
    }
  }
}
