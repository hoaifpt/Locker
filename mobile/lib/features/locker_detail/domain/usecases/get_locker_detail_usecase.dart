import '../entities/locker_detail.dart';
import '../repositories/i_locker_detail_repository.dart';

class GetLockerDetailUsecase {
  final ILockerDetailRepository _repo;
  const GetLockerDetailUsecase(this._repo);

  Future<LockerDetail> call(String lockerId) => _repo.getLockerDetail(lockerId);
}
