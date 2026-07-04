import '../entities/locker_size.dart';
import '../entities/send_receive_order.dart';
import '../entities/storage_duration.dart';

abstract class ISendReceiveRepository {
  Future<List<LockerSize>> getAvailableLockerSizes();
  Future<List<StorageDuration>> getStorageDurations();
  Future<Map<String, dynamic>> createSendReceiveOrder({
    required String lockerId,
    required int slotIndex,
    required String packageId,
    required String mobileNumber,
    required DateTime checkInTime,
    required int durationHours,
    String? couponCode,
    String? notes,
  });
  Future<SendReceiveOrder> getOrderById(String orderId);
  Future<void> confirmOrder(String orderId);
}
