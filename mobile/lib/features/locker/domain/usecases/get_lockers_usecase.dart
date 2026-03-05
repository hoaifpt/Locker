import '../entities/locker.dart';
import '../repositories/i_locker_repository.dart';

class GetLockersUsecase {
  final ILockerRepository _repo;
  GetLockersUsecase(this._repo);

  Future<List<Locker>> call() => _repo.getLockers();
}
