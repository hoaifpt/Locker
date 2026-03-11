import '../entities/locker_slot.dart';
import '../repositories/i_locker_map_repository.dart';

class GetLockerSlotsUsecase {
  final ILockerMapRepository _repo;
  const GetLockerSlotsUsecase(this._repo);

  Future<List<LockerSlot>> call() => _repo.getLockerSlots();
}
