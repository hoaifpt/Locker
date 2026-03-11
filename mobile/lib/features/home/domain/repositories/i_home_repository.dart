import '../../../locker/domain/entities/locker.dart';
import '../entities/active_locker.dart';

/// Abstract contract — data layer phải implement
abstract class IHomeRepository {
  Future<List<ActiveLocker>> getActiveLockers();
  Future<List<Locker>> getNearbyLockers();
}
