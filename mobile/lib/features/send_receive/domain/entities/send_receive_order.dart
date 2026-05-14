import 'locker_size.dart';
import 'storage_duration.dart';

class SendReceiveOrder {
  final String id;
  final String lockerId;
  final String lockerCode;
  final String location;
  final LockerSize size;
  final StorageDuration duration;
  final int estimatedFee;
  final String status;
  final DateTime createdAt;

  const SendReceiveOrder({
    required this.id,
    required this.lockerId,
    required this.lockerCode,
    required this.location,
    required this.size,
    required this.duration,
    required this.estimatedFee,
    required this.status,
    required this.createdAt,
  });
}
