import '../../domain/entities/photo_confirmation_data.dart';
import '../../../send_success/domain/entities/send_success_info.dart';

class PhotoConfirmationState {
  final bool isLoading;
  final bool flashOn;
  final PhotoConfirmationData? data;
  final String? errorMessage;
  final String? feedbackMessage;
  final SendSuccessRequest? navigateToSendSuccess;

  const PhotoConfirmationState({
    required this.isLoading,
    required this.flashOn,
    required this.data,
    this.errorMessage,
    this.feedbackMessage,
    this.navigateToSendSuccess,
  });

  factory PhotoConfirmationState.initial() {
    return const PhotoConfirmationState(
      isLoading: true,
      flashOn: false,
      data: null,
    );
  }

  PhotoConfirmationState copyWith({
    bool? isLoading,
    bool? flashOn,
    PhotoConfirmationData? data,
    String? errorMessage,
    String? feedbackMessage,
    SendSuccessRequest? navigateToSendSuccess,
    bool clearError = false,
    bool clearFeedback = false,
    bool clearNavigation = false,
  }) {
    return PhotoConfirmationState(
      isLoading: isLoading ?? this.isLoading,
      flashOn: flashOn ?? this.flashOn,
      data: data ?? this.data,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      navigateToSendSuccess: clearNavigation
          ? null
          : (navigateToSendSuccess ?? this.navigateToSendSuccess),
    );
  }
}
