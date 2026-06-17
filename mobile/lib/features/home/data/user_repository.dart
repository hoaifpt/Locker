import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/i_user_repository.dart';
import 'models/user_model.dart';

class UserRepository implements IUserRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<User> getProfile() async {
    try {
      // Assuming the endpoint to get user profile is '/users/me'
      final response = await _apiClient.client.get(ApiEndpoints.userMe);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw NetworkException('Failed to load user profile');
    } catch (e) {
      throw NetworkException('Error fetching user profile: $e');
    }
  }
}
