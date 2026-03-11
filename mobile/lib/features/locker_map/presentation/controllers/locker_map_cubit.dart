import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/locker_slot.dart';
import '../../domain/usecases/get_locker_slots_usecase.dart';
import '../../domain/usecases/open_locker_usecase.dart';
import 'locker_map_state.dart';

class LockerMapCubit extends Cubit<LockerMapState> {
  final GetLockerSlotsUsecase _getLockerSlots;
  final OpenLockerUsecase _openLocker;

  LockerMapCubit({
    required GetLockerSlotsUsecase getLockerSlots,
    required OpenLockerUsecase openLocker,
  })  : _getLockerSlots = getLockerSlots,
        _openLocker = openLocker,
        super(const LockerMapInitial());

  Future<void> load() async {
    emit(const LockerMapLoading());
    try {
      final slots = await _getLockerSlots();
      // Tự động chọn tủ của mình nếu có
      final mine =
          slots.where((s) => s.status == LockerStatus.mine).firstOrNull;
      emit(LockerMapLoaded(slots: slots, selectedSlot: mine));
    } on AppException catch (e) {
      emit(LockerMapError(e.message));
    } catch (e) {
      emit(LockerMapError(e.toString()));
    }
  }

  void selectSlot(LockerSlot slot) {
    final current = state;
    if (current is! LockerMapLoaded) return;
    emit(current.copyWith(selectedSlot: slot));
  }

  void setFilter(LockerFilter filter) {
    final current = state;
    if (current is! LockerMapLoaded) return;
    emit(current.copyWith(activeFilter: filter));
  }

  Future<void> openLocker() async {
    final current = state;
    if (current is! LockerMapLoaded || current.selectedSlot == null) return;
    final slot = current.selectedSlot!;
    emit(current.copyWith(isOpening: true));
    try {
      await _openLocker(slot.id);
      emit(LockerOpenSuccess(slot.code));
    } on AppException catch (e) {
      emit(LockerMapError(e.message));
    } catch (e) {
      emit(LockerMapError(e.toString()));
    }
  }
}
