import '../entities/locker_overdue_info.dart';

abstract class ILockerOverdueRepository {
  Future<LockerOverdueInfo> fetchOverdueInfo();
}
