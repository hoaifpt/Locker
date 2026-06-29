import 'package:locker_mobile/features/personal_info/domain/entities/personal_info_overview.dart';

abstract class IChangePasswordRepository {
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
