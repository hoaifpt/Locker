import '../entities/locker.dart';
import '../repositories/i_locker_repository.dart';

class GetAvailableLockersUseCase {
  final ILockerRepository _repo;
  GetAvailableLockersUseCase(this._repo);

  Future<List<Locker>> call() => _repo.getAvailableLockers();
}
