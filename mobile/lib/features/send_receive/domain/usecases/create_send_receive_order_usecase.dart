import '../entities/send_receive_order.dart';
import '../repositories/i_send_receive_repository.dart';

class CreateSendReceiveOrderUseCase {
  final ISendReceiveRepository repository;

  CreateSendReceiveOrderUseCase({required this.repository});

  Future<SendReceiveOrder> call({
    required String lockerId,
    required String sizeId,
    required String durationId,
  }) {
    return repository.createSendReceiveOrder(
      lockerId: lockerId,
      sizeId: sizeId,
      durationId: durationId,
    );
  }
}
