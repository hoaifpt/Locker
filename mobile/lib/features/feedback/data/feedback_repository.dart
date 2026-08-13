import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/feedback.dart';
import '../domain/repositories/i_feedback_repository.dart';
import 'models/feedback_model.dart';

class FeedbackRepository implements IFeedbackRepository {
  FeedbackRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<UserFeedback?> getMine() async {
    try {
      final response = await _apiClient.client.get(ApiEndpoints.feedbackMe);
      if (response.statusCode == 204 || response.data == null) return null;

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return FeedbackModel.fromJson(data);
      }

      throw NetworkException('Không thể tải phản hồi của bạn.');
    } on DioException catch (error) {
      throw NetworkException(_messageFrom(error, 'Không thể tải phản hồi.'));
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Dữ liệu phản hồi không hợp lệ.');
    }
  }

  @override
  Future<UserFeedback> upsert({
    required int rating,
    required FeedbackTopic topic,
    required String content,
    required String pageUrl,
  }) async {
    try {
      final response = await _apiClient.client.put(
        ApiEndpoints.feedbackMe,
        data: {
          'rating': rating,
          'topic': topic.value,
          'content': content,
          'pageUrl': pageUrl,
        },
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return FeedbackModel.fromJson(data);
      }

      throw NetworkException('Không thể gửi phản hồi.');
    } on DioException catch (error) {
      throw NetworkException(_messageFrom(error, 'Không thể gửi phản hồi.'));
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Phản hồi từ máy chủ không hợp lệ.');
    }
  }

  String _messageFrom(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['title'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return fallback;
  }
}
