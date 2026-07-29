import '../entities/notification.dart';

abstract class INotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> registerDevice({required String deviceToken, required String platform});
}
