import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_as_read_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/register_device_usecase.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUsecase getNotifications;
  final MarkAsReadUsecase markAsRead;
  final MarkAllAsReadUsecase markAllAsRead;
  final RegisterDeviceUsecase registerDevice;

  NotificationCubit({
    required this.getNotifications,
    required this.markAsRead,
    required this.markAllAsRead,
    required this.registerDevice,
  }) : super(const NotificationInitial());

  Future<void> fetchNotifications() async {
    try {
      emit(const NotificationLoading());
      final notifications = await getNotifications();
      emit(NotificationLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await markAsRead(notificationId);
      // Refresh notifications after marking as read
      final notifications = await getNotifications();
      emit(NotificationLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await markAllAsRead();
      // Refresh notifications after marking all as read
      final notifications = await getNotifications();
      emit(NotificationLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> registerFCMToken({required String deviceToken, required String platform}) async {
    try {
      await registerDevice(deviceToken: deviceToken, platform: platform);
      // Sau khi đăng ký thiết bị thành công, tự động fetch danh sách thông báo về luôn
      await fetchNotifications();
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }
}
