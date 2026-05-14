import '../entities/locker_size.dart';
import '../entities/send_receive_order.dart';
import '../entities/storage_duration.dart';

abstract class ISendReceiveRepository {
  Future<List<LockerSize>> getAvailableLockerSizes();
  Future<List<StorageDuration>> getStorageDurations();
  Future<SendReceiveOrder> createSendReceiveOrder({
    required String lockerId,
    required String sizeId,
    required String durationId,
  });
  Future<SendReceiveOrder> getOrderById(String orderId);
  Future<void> confirmOrder(String orderId);
}
