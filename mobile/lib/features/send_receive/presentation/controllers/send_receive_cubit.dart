import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_send_receive_order_usecase.dart';
import '../../domain/usecases/get_available_locker_sizes_usecase.dart';
import '../../domain/usecases/get_storage_durations_usecase.dart';
import 'send_receive_state.dart';

class SendReceiveCubit extends Cubit<SendReceiveState> {
  final GetAvailableLockerSizesUseCase _getLockerSizes;
  final GetStorageDurationsUseCase _getStorageDurations;
  final CreateSendReceiveOrderUseCase _createOrder;

  SendReceiveCubit({
    required GetAvailableLockerSizesUseCase getLockerSizes,
    required GetStorageDurationsUseCase getStorageDurations,
    required CreateSendReceiveOrderUseCase createOrder,
  })  : _getLockerSizes = getLockerSizes,
        _getStorageDurations = getStorageDurations,
        _createOrder = createOrder,
        super(SendReceiveState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final sizes = await _getLockerSizes();
      final durations = await _getStorageDurations();

      emit(state.copyWith(
        isLoading: false,
        lockerSizes: sizes,
        storageDurations: durations,
        selectedSizeId: sizes.isNotEmpty ? sizes.first.id : null,
        selectedDurationId: durations.isNotEmpty ? durations[1].id : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải dữ liệu: $e',
      ));
    }
  }

  void selectSize(String sizeId) {
    emit(state.copyWith(selectedSizeId: sizeId));
  }

  void selectDuration(String durationId) {
    emit(state.copyWith(selectedDurationId: durationId));
  }

  Future<void> createOrder(String lockerId) async {
    if (state.selectedSizeId == null || state.selectedDurationId == null) {
      emit(state.copyWith(
        errorMessage: 'Vui lòng chọn kích thước và thời gian gửi',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      final order = await _createOrder(
        lockerId: lockerId,
        sizeId: state.selectedSizeId!,
        durationId: state.selectedDurationId!,
      );

      emit(state.copyWith(
        isLoading: false,
        currentOrder: order,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tạo đơn hàng: $e',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
