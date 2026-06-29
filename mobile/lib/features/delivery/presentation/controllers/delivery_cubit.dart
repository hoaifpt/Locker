import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/delivery_request.dart';
import '../../domain/usecases/create_send_request_usecase.dart';
import '../../domain/usecases/get_delivery_package_sizes_usecase.dart';
import '../../domain/usecases/submit_receive_code_usecase.dart';
import '../../../../features/locker/data/locker_repository.dart';
import 'delivery_state.dart';

class DeliveryCubit extends Cubit<DeliveryState> {
  final GetDeliveryPackageSizes _getPackageSizes;
  final CreateSendRequest _createSendRequest;
  final SubmitReceiveCode _submitReceiveCode;
  final LockerRepository _lockerRepository;

  DeliveryCubit({
    required GetDeliveryPackageSizes getPackageSizes,
    required CreateSendRequest createSendRequest,
    required SubmitReceiveCode submitReceiveCode,
    required LockerRepository lockerRepository,
  }) : _getPackageSizes = getPackageSizes,
       _createSendRequest = createSendRequest,
       _submitReceiveCode = submitReceiveCode,
       _lockerRepository = lockerRepository,
       super(DeliveryState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    try {
      final packageSizes = await _getPackageSizes();
      final lockers = await _lockerRepository.getLockers();
      emit(
        state.copyWith(
          isLoading: false,
          packageSizes: packageSizes,
          lockers: lockers,
          selectedSizeId: packageSizes.isNotEmpty ? packageSizes.first.id : '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          feedbackMessage: 'Lỗi tải dữ liệu: $e',
        ),
      );
    }
  }

  void selectSize(String sizeId) {
    emit(state.copyWith(selectedSizeId: sizeId, clearMessage: true));
  }

  void selectLocation(String location) {
    emit(
      state.copyWith(
        selectedLocation: location,
        selectedLockerId: null, // Reset tủ khi đổi địa chỉ
        clearMessage: true,
      ),
    );
  }

  void selectLocker(String lockerId, int slotIndex) {
    emit(
      state.copyWith(
        selectedLockerId: lockerId,
        selectedSlotIndex: slotIndex,
        clearMessage: true,
      ),
    );
  }

  void updateSenderName(String value) {
    emit(state.copyWith(senderName: value, clearMessage: true));
  }

  void updateReceiverPhone(String value) {
    emit(state.copyWith(receiverPhone: value, clearMessage: true));
  }

  void updateReceiveCode(String value) {
    emit(state.copyWith(receiveCode: value, clearMessage: true));
  }

  Future<void> submitSendRequest() async {
    if (state.selectedSizeId.isEmpty) {
      emit(
        state.copyWith(feedbackMessage: 'Vui lòng chọn kích thước tủ trước.'),
      );
      return;
    }
    if (state.selectedLockerId == null) {
      emit(state.copyWith(feedbackMessage: 'Vui lòng chọn một tủ trống.'));
      return;
    }
    if (state.senderName.trim().isEmpty) {
      emit(state.copyWith(feedbackMessage: 'Vui lòng nhập tên người gửi.'));
      return;
    }
    if (state.receiverPhone.trim().isEmpty) {
      emit(
        state.copyWith(
          feedbackMessage: 'Vui lòng nhập số điện thoại người nhận.',
        ),
      );
      return;
    }

    // Tìm package size tương ứng với ID đã chọn
    String selectedSizeLabel = '';
    for (var pkg in state.packageSizes) {
      if (pkg.id == state.selectedSizeId) {
        selectedSizeLabel = pkg.size;
        break;
      }
    }
    if (selectedSizeLabel.isEmpty && state.packageSizes.isNotEmpty) {
      selectedSizeLabel = state.packageSizes.first.size;
    }

    final message = await _createSendRequest(
      SendDeliveryRequest(
        packageSizeId: state.selectedSizeId,
        packageSize: selectedSizeLabel,
        senderName: state.senderName.trim(),
        receiverPhone: state.receiverPhone.trim(),
        lockerId: state.selectedLockerId!,
        slotIndex: state.selectedSlotIndex,
      ),
    );

    emit(state.copyWith(feedbackMessage: message));
  }

  Future<void> submitReceiveRequest() async {
    final code = state.receiveCode.trim();
    if (code.isEmpty) {
      emit(state.copyWith(feedbackMessage: 'Vui lòng nhập mã nhận hàng.'));
      return;
    }

    final message = await _submitReceiveCode(code);
    emit(state.copyWith(feedbackMessage: message));
  }
}
