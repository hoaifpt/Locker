import '../entities/notification.dart';
import '../repositories/i_notification_repository.dart';

class GetNotificationsUsecase {
  final INotificationRepository repository;

  GetNotificationsUsecase({required this.repository});

  Future<List<NotificationEntity>> call() => repository.getNotifications();
}
