import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/usecases/get_locker_detail_usecase.dart';
import '../../domain/usecases/open_locker_detail_usecase.dart';
import '../../domain/usecases/update_auto_lock_usecase.dart';
import '../../domain/usecases/update_intrusion_alert_usecase.dart';
import 'locker_detail_state.dart';

class LockerDetailCubit extends Cubit<LockerDetailState> {
  final GetLockerDetailUsecase _getDetail;
  final OpenLockerDetailUsecase _openLocker;
  final UpdateAutoLockUsecase _updateAutoLock;
  final UpdateIntrusionAlertUsecase _updateIntrusionAlert;
  final String lockerId;

  LockerDetailCubit({
    required this.lockerId,
    required GetLockerDetailUsecase getDetail,
    required OpenLockerDetailUsecase openLocker,
    required UpdateAutoLockUsecase updateAutoLock,
    required UpdateIntrusionAlertUsecase updateIntrusionAlert,
  })  : _getDetail = getDetail,
        _openLocker = openLocker,
        _updateAutoLock = updateAutoLock,
        _updateIntrusionAlert = updateIntrusionAlert,
        super(const LockerDetailInitial());

  Future<void> load() async {
    emit(const LockerDetailLoading());
    try {
      final detail = await _getDetail(lockerId);
      emit(LockerDetailLoaded(detail: detail));
    } on AppException catch (e) {
      emit(LockerDetailError(e.message));
    } catch (e) {
      emit(LockerDetailError(e.toString()));
    }
  }

  Future<void> openLocker() async {
    final current = state;
    if (current is! LockerDetailLoaded) return;
    emit(current.copyWith(isOpening: true));
    try {
      await _openLocker(lockerId);
      emit(LockerDetailOpenSuccess(current.detail.code));
    } on AppException catch (e) {
      emit(LockerDetailError(e.message));
    } catch (e) {
      emit(LockerDetailError(e.toString()));
    }
  }

  Future<void> toggleAutoLock() async {
    final current = state;
    if (current is! LockerDetailLoaded || current.isUpdating) return;
    emit(current.copyWith(isUpdating: true));
    try {
      final updated = await _updateAutoLock(
        lockerId,
        enabled: !current.detail.isAutoLockEnabled,
      );
      emit(LockerDetailLoaded(detail: updated));
    } on AppException catch (e) {
      emit(LockerDetailError(e.message));
    } catch (e) {
      emit(LockerDetailError(e.toString()));
    }
  }

  Future<void> toggleIntrusionAlert() async {
    final current = state;
    if (current is! LockerDetailLoaded || current.isUpdating) return;
    emit(current.copyWith(isUpdating: true));
    try {
      final updated = await _updateIntrusionAlert(
        lockerId,
        enabled: !current.detail.isIntrusionAlertEnabled,
      );
      emit(LockerDetailLoaded(detail: updated));
    } on AppException catch (e) {
      emit(LockerDetailError(e.message));
    } catch (e) {
      emit(LockerDetailError(e.toString()));
    }
  }
}
