import '../entities/feedback.dart';
import '../repositories/i_feedback_repository.dart';

class UpsertFeedbackUsecase {
  const UpsertFeedbackUsecase(this._repository);

  final IFeedbackRepository _repository;

  Future<UserFeedback> call({
    required int rating,
    required FeedbackTopic topic,
    required String content,
    required String pageUrl,
  }) {
    return _repository.upsert(
      rating: rating,
      topic: topic,
      content: content,
      pageUrl: pageUrl,
    );
  }
}
