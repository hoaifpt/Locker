import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/feedback.dart';
import '../../domain/usecases/get_my_feedback_usecase.dart';
import '../../domain/usecases/upsert_feedback_usecase.dart';
import 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit({
    required GetMyFeedbackUsecase getMyFeedback,
    required UpsertFeedbackUsecase upsertFeedback,
  }) : _getMyFeedback = getMyFeedback,
       _upsertFeedback = upsertFeedback,
       super(const FeedbackState());

  final GetMyFeedbackUsecase _getMyFeedback;
  final UpsertFeedbackUsecase _upsertFeedback;

  Future<void> load() async {
    emit(state.copyWith(status: FeedbackLoadStatus.loading, clearError: true));

    try {
      final feedback = await _getMyFeedback();
      emit(
        state.copyWith(
          status: FeedbackLoadStatus.ready,
          feedback: feedback,
          clearFeedback: feedback == null,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeedbackLoadStatus.failure,
          errorMessage: _readableError(error),
        ),
      );
    }
  }

  Future<bool> submit({
    required int rating,
    required FeedbackTopic topic,
    required String content,
  }) async {
    if (state.status != FeedbackLoadStatus.ready || state.isSubmitting) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final feedback = await _upsertFeedback(
        rating: rating,
        topic: topic,
        content: content,
        pageUrl: '/settings',
      );
      emit(
        state.copyWith(
          feedback: feedback,
          isSubmitting: false,
          clearError: true,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: _readableError(error),
          isSubmitting: false,
        ),
      );
      return false;
    }
  }

  String _readableError(Object error) {
    final message = error.toString();
    return message
        .replaceFirst('NetworkException: ', '')
        .replaceFirst('AppException: ', '')
        .trim();
  }
}
