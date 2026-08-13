import '../entities/feedback.dart';
import '../repositories/i_feedback_repository.dart';

class GetMyFeedbackUsecase {
  const GetMyFeedbackUsecase(this._repository);

  final IFeedbackRepository _repository;

  Future<UserFeedback?> call() => _repository.getMine();
}
