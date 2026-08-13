import '../../domain/entities/feedback.dart';

enum FeedbackLoadStatus { initial, loading, ready, failure }

class FeedbackState {
  const FeedbackState({
    this.status = FeedbackLoadStatus.initial,
    this.feedback,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final FeedbackLoadStatus status;
  final UserFeedback? feedback;
  final String? errorMessage;
  final bool isSubmitting;

  FeedbackState copyWith({
    FeedbackLoadStatus? status,
    UserFeedback? feedback,
    bool clearFeedback = false,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return FeedbackState(
      status: status ?? this.status,
      feedback: clearFeedback ? null : feedback ?? this.feedback,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
