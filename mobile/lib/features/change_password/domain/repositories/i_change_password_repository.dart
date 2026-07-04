
abstract class IChangePasswordRepository {
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
