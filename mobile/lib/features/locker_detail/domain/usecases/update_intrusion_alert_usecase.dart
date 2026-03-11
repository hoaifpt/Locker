import '../entities/locker_detail.dart';
import '../repositories/i_locker_detail_repository.dart';

class UpdateIntrusionAlertUsecase {
  final ILockerDetailRepository _repo;
  const UpdateIntrusionAlertUsecase(this._repo);

  Future<LockerDetail> call(String lockerId, {required bool enabled}) =>
      _repo.updateIntrusionAlert(lockerId, enabled: enabled);
}
