import '../../../locker/domain/entities/locker.dart';
import '../repositories/i_home_repository.dart';

class GetNearbyLockers {
  final IHomeRepository _repo;
  GetNearbyLockers(this._repo);

  Future<List<Locker>> call() => _repo.getNearbyLockers();
}
