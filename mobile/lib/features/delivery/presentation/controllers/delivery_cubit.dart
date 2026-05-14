import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/delivery_request.dart';
import '../../domain/usecases/create_send_request_usecase.dart';
import '../../domain/usecases/get_delivery_package_sizes_usecase.dart';
import '../../domain/usecases/submit_receive_code_usecase.dart';
import 'delivery_state.dart';

class DeliveryCubit extends Cubit<DeliveryState> {
  final GetDeliveryPackageSizes _getPackageSizes;
  final CreateSendRequest _createSendRequest;
  final SubmitReceiveCode _submitReceiveCode;

  DeliveryCubit({
    required GetDeliveryPackageSizes getPackageSizes,
    required CreateSendRequest createSendRequest,
    required SubmitReceiveCode submitReceiveCode,
  })  : _getPackageSizes = getPackageSizes,
        _createSendRequest = createSendRequest,
        _submitReceiveCode = submitReceiveCode,
        super(DeliveryState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    final packageSizes = await _getPackageSizes();
    emit(state.copyWith(
      isLoading: false,
      packageSizes: packageSizes,
      selectedSizeId: packageSizes.isNotEmpty ? packageSizes.first.id : '',
    ));
  }

  void selectSize(String sizeId) {
    emit(state.copyWith(selectedSizeId: sizeId, clearMessage: true));
  }

  void updateSendCode(String value) {
    emit(state.copyWith(sendCode: value, clearMessage: true));
  }

  void updateReceiveCode(String value) {
    emit(state.copyWith(receiveCode: value, clearMessage: true));
  }

  Future<void> submitSendRequest() async {
    if (state.selectedSizeId.isEmpty) {
      emit(state.copyWith(
          feedbackMessage: 'Vui lòng chọn kích thước tủ trước.'));
      return;
    }

    final message = await _createSendRequest(
      SendDeliveryRequest(
        packageSizeId: state.selectedSizeId,
        trackingCode:
            state.sendCode.trim().isEmpty ? null : state.sendCode.trim(),
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
