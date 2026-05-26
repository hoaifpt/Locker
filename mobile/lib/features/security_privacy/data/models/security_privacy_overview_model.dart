import '../../domain/entities/security_privacy_action.dart';
import '../../domain/entities/security_privacy_data.dart';
import '../../domain/entities/security_privacy_item.dart';
import '../../domain/entities/security_privacy_overview.dart';

class SecurityPrivacyOverviewModel extends SecurityPrivacyOverview {
  const SecurityPrivacyOverviewModel({
    required super.data,
    required super.settings,
    required super.actions,
  });

  factory SecurityPrivacyOverviewModel.fromJson(Map<String, dynamic> json) {
    return SecurityPrivacyOverviewModel(
      data: SecurityPrivacyData(
        faceIdEnabled: json['faceIdEnabled'] as bool? ?? true,
        twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? true,
        loginAlertEnabled: json['loginAlertEnabled'] as bool? ?? true,
      ),
      settings: [
        SecurityPrivacyItem(
          title: 'Xác thực sinh trắc học',
          subtitle: 'Sử dụng FaceID hoặc TouchID',
          isEnabled: json['faceIdEnabled'] as bool? ?? true,
        ),
        SecurityPrivacyItem(
          title: 'Thông báo đăng nhập',
          subtitle: 'Cảnh báo khi có thiết bị mới',
          isEnabled: json['loginAlertEnabled'] as bool? ?? true,
        ),
        SecurityPrivacyItem(
          title: 'Bảo mật 2 lớp (2FA)',
          subtitle: 'Mã OTP gửi qua số điện thoại',
          isEnabled: json['twoFactorEnabled'] as bool? ?? true,
        ),
      ],
      actions: const [
        SecurityPrivacyAction(
          title: 'Đổi mật khẩu',
          subtitle: 'Cập nhật mật khẩu định kỳ',
        ),
        SecurityPrivacyAction(
          title: 'Thiết bị tin cậy',
          subtitle: 'Quản lý 2 thiết bị đang đăng nhập',
        ),
      ],
    );
  }
}
