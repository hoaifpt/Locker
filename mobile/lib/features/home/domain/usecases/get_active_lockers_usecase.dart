import '../entities/active_locker.dart';
import '../repositories/i_home_repository.dart';

class GetActiveLockers {
  final IHomeRepository _repo;
  GetActiveLockers(this._repo);

  Future<List<ActiveLocker>> call() => _repo.getActiveLockers();
}
