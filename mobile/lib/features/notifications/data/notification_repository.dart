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
      final response = await _apiClient.client.get(
        ApiEndpoints.notificationsMy,
      );

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
        'Error marking notification as read: ${e.message}',
      );
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
        'Error marking all notifications as read: ${e.message}',
      );
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> registerDevice({
    required String deviceToken,
    required String platform,
  }) async {
    try {
      // 1. Gửi request POST lên backend 
      final response = await _apiClient.client.post(
        ApiEndpoints.registerDevice,
        data: {
          'deviceToken': deviceToken, 
          'platform': platform,
        },
      );

      // Thay vì return true/false, ta chỉ cần check nếu không thành công thì throw lỗi
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw AppException('Cập nhật Device Token thất bại với code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Phiên đăng nhập hết hạn, không thể cập nhật token.',
        );
      }
      throw NetworkException(
        e.message ?? 'Lỗi kết nối khi đồng bộ Device Token',
      );
    } catch (e) {
      throw AppException('Lỗi cập nhật Device Token: $e');
    }
  }
}
