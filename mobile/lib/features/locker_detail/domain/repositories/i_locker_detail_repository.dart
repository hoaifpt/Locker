import '../entities/locker_detail.dart';

abstract class ILockerDetailRepository {
  Future<LockerDetail> getLockerDetail(String lockerId);
  Future<void> openLocker(String lockerId);
  Future<LockerDetail> updateAutoLock(String lockerId, {required bool enabled});
  Future<LockerDetail> updateIntrusionAlert(String lockerId,
      {required bool enabled});
}
