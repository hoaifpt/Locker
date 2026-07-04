import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/locker_detail.dart';
import '../domain/repositories/i_locker_detail_repository.dart';
import 'models/locker_detail_model.dart';

final _guidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
);

class LockerDetailRepository implements ILockerDetailRepository {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/lockers/{id} — trả về chi tiết ngăn tủ
  @override
  Future<LockerDetail> getLockerDetail(String lockerId) async {
    try {
      final normalizedId = lockerId.trim();
      if (normalizedId.isEmpty) {
        throw NetworkException('Không có mã tủ để tải');
      }

      final resolvedId = await _resolveLockerId(normalizedId);
      final response = await _apiClient.client.get(
        '/lockers/${Uri.encodeComponent(resolvedId)}',
      );
      if (response.statusCode == 200) {
        return LockerDetailModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw NetworkException('Không tải được chi tiết tủ');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Lỗi khi tải chi tiết tủ: $e');
    }
  }

  Future<String> _resolveLockerId(String lockerId) async {
    if (_guidPattern.hasMatch(lockerId)) {
      return lockerId;
    }

    final response = await _apiClient.client.get('/lockers');
    if (response.statusCode != 200 || response.data is! List) {
      return lockerId;
    }

    final lockers = response.data as List;
    for (final entry in lockers) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }

      final candidateId = (entry['_id'] ?? entry['id'])?.toString() ?? '';
      final candidateCode = (entry['name'] ?? entry['code'])?.toString() ?? '';
      final normalizedInput = lockerId.toLowerCase();
      final normalizedCode = candidateCode.toLowerCase();
      final normalizedCodeWithoutSpaces = normalizedCode.replaceAll(' ', '');
      final normalizedInputWithoutSpaces = normalizedInput.replaceAll(' ', '');

      if (candidateId.isNotEmpty &&
          (candidateId.toLowerCase() == normalizedInput ||
              candidateId.toLowerCase() == normalizedInputWithoutSpaces)) {
        return candidateId;
      }

      if (candidateCode.isNotEmpty &&
          (normalizedCode == normalizedInput ||
              normalizedCodeWithoutSpaces == normalizedInputWithoutSpaces)) {
        return candidateId.isNotEmpty ? candidateId : lockerId;
      }
    }

    return lockerId;
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
  Future<LockerDetail> updateAutoLock(
    String lockerId, {
    required bool enabled,
  }) async {
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
  Future<LockerDetail> updateIntrusionAlert(
    String lockerId, {
    required bool enabled,
  }) async {
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
