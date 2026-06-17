import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/exceptions/app_exception.dart';
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
          await _apiClient.client.get(ApiEndpoints.notificationsMy);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      throw NetworkException('Failed to load notifications');
    } on DioException catch (e) {
      throw NetworkException('Error loading notifications: ${e.message}');
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.client.post(
        ApiEndpoints.notificationMarkAsRead(notificationId),
      );
    } on DioException catch (e) {
      throw NetworkException(
          'Error marking notification as read: ${e.message}');
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.client.post(ApiEndpoints.notificationsMarkAllAsRead);
    } on DioException catch (e) {
      throw NetworkException(
          'Error marking all notifications as read: ${e.message}');
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }
}
