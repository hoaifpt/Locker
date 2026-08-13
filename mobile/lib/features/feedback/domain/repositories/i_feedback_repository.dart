import '../entities/feedback.dart';

abstract interface class IFeedbackRepository {
  Future<UserFeedback?> getMine();

  Future<UserFeedback> upsert({
    required int rating,
    required FeedbackTopic topic,
    required String content,
    required String pageUrl,
  });
}
