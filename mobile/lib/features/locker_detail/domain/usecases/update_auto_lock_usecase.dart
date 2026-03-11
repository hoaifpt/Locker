import '../entities/locker_detail.dart';
import '../repositories/i_locker_detail_repository.dart';

class UpdateAutoLockUsecase {
  final ILockerDetailRepository _repo;
  const UpdateAutoLockUsecase(this._repo);

  Future<LockerDetail> call(String lockerId, {required bool enabled}) =>
      _repo.updateAutoLock(lockerId, enabled: enabled);
}
