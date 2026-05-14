import '../entities/send_success_info.dart';
import '../repositories/i_send_success_repository.dart';

class GetSendSuccessUsecase {
  final ISendSuccessRepository _repository;
  GetSendSuccessUsecase(this._repository);

  Future<SendSuccessInfo> call(SendSuccessRequest? request) {
    return _repository.getSendSuccessInfo(request);
  }
}
