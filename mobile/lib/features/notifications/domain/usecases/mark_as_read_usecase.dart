import '../repositories/i_notification_repository.dart';

class MarkAsReadUsecase {
  final INotificationRepository repository;

  MarkAsReadUsecase({required this.repository});

  Future<void> call(String notificationId) =>
      repository.markAsRead(notificationId);
}
