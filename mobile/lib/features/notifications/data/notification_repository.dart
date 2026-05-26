import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../notifications/domain/entities/notification.dart';
import '../../notifications/domain/repositories/i_notification_repository.dart';
import 'models/notification_model.dart';

class NotificationRepository implements INotificationRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.notificationsGetMy);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Return empty list on error for now, or throw
      return [];
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.client
          .post(ApiEndpoints.notificationsMarkAsRead(notificationId));
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.client.post(ApiEndpoints.notificationsMarkAllAsRead);
    } catch (e) {
      // Handle error
    }
  }
}
