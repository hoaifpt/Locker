import '../repositories/i_locker_detail_repository.dart';

class OpenLockerDetailUsecase {
  final ILockerDetailRepository _repo;
  const OpenLockerDetailUsecase(this._repo);

  Future<void> call(String lockerId) => _repo.openLocker(lockerId);
}
