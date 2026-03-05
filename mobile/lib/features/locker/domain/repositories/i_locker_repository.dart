import '../entities/locker.dart';

abstract class ILockerRepository {
  Future<List<Locker>> getLockers();
  Future<List<Locker>> getAvailableLockers();
}
