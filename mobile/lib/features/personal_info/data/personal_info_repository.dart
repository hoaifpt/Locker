import '../domain/entities/personal_info_overview.dart';
import '../domain/repositories/i_personal_info_repository.dart';
import 'models/personal_info_overview_model.dart';

class PersonalInfoRepository implements IPersonalInfoRepository {
  @override
  Future<PersonalInfoOverview> getOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return PersonalInfoOverviewModel.fromJson({
      'data': {
        'fullName': 'Nguyễn Văn Minh',
        'phoneNumber': '090 **** 888',
        'email': 'minh.nguyen@example.com',
        'address': '221B Baker Street, Quận 1, TP. Hồ Chí Minh',
        'birthday': '15/05/1990',
        'membershipTier': 'Thành viên Vàng',
        'avatarUrl': 'https://placehold.co/104x104',
      },
      'items': [
        {
          'label': 'HỌ VÀ TÊN',
          'value': 'Nguyễn Văn Minh',
          'hint': 'Tên hiển thị trên hồ sơ',
          'isEditable': true,
        },
        {
          'label': 'SỐ ĐIỆN THOẠI',
          'value': '090 **** 888',
          'hint': 'Đã liên kết với tài khoản',
          'isEditable': true,
        },
        {
          'label': 'EMAIL',
          'value': 'minh.nguyen@example.com',
          'hint': 'Nhận thông báo và xác thực',
          'isEditable': true,
        },
        {
          'label': 'ĐỊA CHỈ',
          'value': '221B Baker Street, Quận 1, TP. Hồ Chí Minh',
          'hint': 'Dùng cho nhận diện giao nhận',
          'isEditable': true,
        },
        {
          'label': 'NGÀY SINH',
          'value': '15/05/1990',
          'hint': 'Phục vụ xác minh danh tính',
          'isEditable': true,
        },
      ],
      'actions': [
        {
          'title': 'Bảo mật & Quyền riêng tư',
          'subtitle': 'FaceID, thông báo đăng nhập, 2FA',
          'route': '/security-privacy',
        },
        {
          'title': 'Ví & thanh toán',
          'subtitle': 'Phương thức thanh toán và lịch sử',
          'route': '/wallet',
        },
      ],
    });
  }
}