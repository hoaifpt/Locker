import '../entities/locker.dart';
import '../repositories/i_locker_repository.dart';

class GetAvailableLockersUsecase {
  final ILockerRepository _repo;
  GetAvailableLockersUsecase(this._repo);

  Future<List<Locker>> call() => _repo.getAvailableLockers();
}
