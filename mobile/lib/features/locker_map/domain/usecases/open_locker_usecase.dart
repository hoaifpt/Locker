import '../repositories/i_locker_map_repository.dart';

class OpenLockerUsecase {
  final ILockerMapRepository _repo;
  const OpenLockerUsecase(this._repo);

  Future<void> call(String lockerId) => _repo.openLocker(lockerId);
}
