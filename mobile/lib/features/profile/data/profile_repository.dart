import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/i_profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.getMe);

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
      throw Exception('Failed to load profile');
    } catch (e) {
      throw Exception('Error loading profile: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.client.post(ApiEndpoints.logout);
    } catch (_) {
      // Handled in auth repository usually
    }
  }
}
