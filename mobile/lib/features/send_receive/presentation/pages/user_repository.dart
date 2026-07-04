import 'package:dio/dio.dart';

import 'package:locker_mobile/core/constants/api_endpoints.dart';
import 'package:locker_mobile/core/exceptions/app_exception.dart';
import 'package:locker_mobile/core/network/api_client.dart';
import 'package:locker_mobile/features/auth/domain/entities/user.dart';
import 'package:locker_mobile/features/auth/domain/repositories/i_user_repository.dart';
import 'package:locker_mobile/features/auth/data/models/user_model.dart';

class UserRepository implements IUserRepository {
  final ApiClient _apiClient;

  UserRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.userMe);

      if (response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException('Không nhận được dữ liệu người dùng.');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] is String) {
        throw ValidationException(e.response!.data['message']);
      }
      throw NetworkException('Lỗi khi tải thông tin người dùng: ${e.message}');
    } catch (e) {
      throw AppException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }
}
