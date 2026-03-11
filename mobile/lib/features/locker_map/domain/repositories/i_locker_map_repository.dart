import '../entities/locker_slot.dart';

abstract class ILockerMapRepository {
  Future<List<LockerSlot>> getLockerSlots();
  Future<void> openLocker(String lockerId);
}
