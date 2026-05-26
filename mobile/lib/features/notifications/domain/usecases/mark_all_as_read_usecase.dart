import '../repositories/i_notification_repository.dart';

class MarkAllAsReadUsecase {
  final INotificationRepository repository;

  MarkAllAsReadUsecase({required this.repository});

  Future<void> call() => repository.markAllAsRead();
}
