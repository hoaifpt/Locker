import '../domain/entities/send_success_info.dart';
import '../domain/repositories/i_send_success_repository.dart';

class SendSuccessRepository implements ISendSuccessRepository {
  @override
  Future<SendSuccessInfo> getSendSuccessInfo(
      SendSuccessRequest? request) async {
    await Future.delayed(const Duration(milliseconds: 120));

    final pin = request?.pin ?? '882109';
    final formattedPin = pin;
    return SendSuccessInfo(
      title: 'Thành công!',
      message: 'Giao dịch của bạn đã hoàn tất.',
      lockerHub: request?.lockerHub ?? 'tủ B3-104',
      pin: formattedPin,
      amount: request?.amount,
      orderCode: request?.orderCode,
    );
  }
}
