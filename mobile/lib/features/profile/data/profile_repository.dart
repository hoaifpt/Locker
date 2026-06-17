import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/i_profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.userMe);

      if (response.statusCode == 200) {
        final data = response.data;
        return UserProfile(
          id: data['id']?.toString() ?? '',
          name: data['fullName']?.toString() ??
              data['username']?.toString() ??
              'User',
          email: data['email']?.toString() ?? '',
          phoneNumber: data['phoneNumber']?.toString() ?? '',
          avatarUrl:
              data['avatarUrl']?.toString() ?? 'https://i.pravatar.cc/150',
          membershipTier: data['membershipTier']?.toString() ?? 'BRONZE MEMBER',
          loyaltyPoints: (data['loyaltyPoints'] as num?)?.toInt() ?? 0,
          address: data['address']?.toString() ?? 'No address provided',
        );
      }
      throw NetworkException('Failed to load user profile');
    } on DioException catch (e) {
      throw NetworkException('Error fetching user profile: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.client.post(ApiEndpoints.authLogout);
    } catch (_) {
      // Handled in auth repository usually
    }
  }
}
