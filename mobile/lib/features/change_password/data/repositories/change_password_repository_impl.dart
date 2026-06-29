import 'package:dio/dio.dart';
import 'package:locker_mobile/features/change_password/domain/repositories/i_change_password_repository.dart';
import 'package:locker_mobile/core/constants/api_endpoints.dart';
import 'package:locker_mobile/core/constants/app_constants.dart';
import 'package:locker_mobile/core/network/api_client.dart';

class ChangePasswordRepositoryImpl implements IChangePasswordRepository {
  final ApiClient _apiClient;

  ChangePasswordRepositoryImpl({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.client.post(
        '${AppConstants.apiBaseUrl}${ApiEndpoints.userChangePassword}',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
