import '../repositories/i_notification_repository.dart';

class RegisterDeviceUsecase {
  final INotificationRepository repository;

  RegisterDeviceUsecase({required this.repository});

  Future<void> call({required String deviceToken, required String platform}) =>
      repository.registerDevice(deviceToken: deviceToken, platform: platform);
}