import '../entities/send_success_info.dart';

abstract class ISendSuccessRepository {
  Future<SendSuccessInfo> getSendSuccessInfo(SendSuccessRequest? request);
}
