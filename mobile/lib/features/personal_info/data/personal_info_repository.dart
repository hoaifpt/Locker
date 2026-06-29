import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

import '../domain/entities/personal_info_overview.dart';
import '../domain/repositories/i_personal_info_repository.dart';
import 'models/personal_info_overview_model.dart';
import '../../../core/constants/api_endpoints.dart';

class PersonalInfoRepository implements IPersonalInfoRepository {
  @override
  Future<PersonalInfoOverview> getOverview() async {
    try {
      final response = await ApiClient().client.get(
        '${AppConstants.apiBaseUrl}${ApiEndpoints.userMe}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiData = response.data;

        // Extract data and construct items based on API response
        final String fullName = apiData['fullName'] ?? '';
        final String email = apiData['email'] ?? '';
        final String phoneNumber = apiData['phoneNumber'] ?? 'Chưa cập nhật';
        final String address = apiData['address'] ?? 'Chưa cập nhật';
        final String membershipTier =
            apiData['role'] ??
            'Người dùng'; // Assuming role maps to membership tier
        final String avatarUrl =
            apiData['avatarUrl'] ?? 'https://placehold.co/104x104';

        return PersonalInfoOverviewModel.fromJson({
          'data': {
            'fullName': fullName,
            'phoneNumber': phoneNumber,
            'email': email,
            'address': address,
            'membershipTier': membershipTier,
            'avatarUrl': avatarUrl,
          },
          'items': [
            {
              'label': 'HỌ VÀ TÊN',
              'value': fullName,
              'hint': 'Tên hiển thị trên hồ sơ',
              'isEditable': true,
            },
            {
              'label': 'SỐ ĐIỆN THOẠI',
              'value': phoneNumber,
              'hint': 'Đã liên kết với tài khoản',
              'isEditable': true,
              'onTap':
                  () {}, // Tôi sẽ gán một hàm trống ở đây, nhưng tôi cần truyền hàm thực tế từ Repository
            },
            {
              'label': 'EMAIL',
              'value': email,
              'hint': 'Nhận thông báo và xác thực',
              'isEditable': true,
            },
            {
              'label': 'ĐỊA CHỈ',
              'value': address,
              'hint': 'Dùng cho nhận diện giao nhận',
              'isEditable': true,
            },
          ],
          'actions': [
            {
              'title': 'Đổi mật khẩu',
              'subtitle': 'Cập nhật mật khẩu mới',
              'route': '/change-password',
            },
            {
              'title': 'Quản lý địa chỉ',
              'subtitle': 'Thêm, sửa hoặc xóa địa chỉ nhận hàng',
              'route': '/addresses',
            },
          ],
        });
      } else {
        throw Exception('Failed to load personal info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load personal info: $e');
    }
  }

  @override
  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      await ApiClient().client.put(
        '${AppConstants.apiBaseUrl}${ApiEndpoints.userMe}',
        data: {
          if (fullName != null) 'fullName': fullName,
          if (email != null) 'email': email,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> updatePhoneNumber(String phoneNumber) async {
    try {
      await ApiClient().client.put(
        '${AppConstants.apiBaseUrl}${ApiEndpoints.userMe}',
        data: {'phoneNumber': phoneNumber},
      );
    } catch (e) {
      throw Exception('Failed to update phone number: $e');
    }
  }
}
