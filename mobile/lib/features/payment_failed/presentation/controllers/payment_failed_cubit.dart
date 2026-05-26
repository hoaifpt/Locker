import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_failed_info.dart';
import '../../domain/usecases/get_payment_failed_usecase.dart';
import 'payment_failed_state.dart';

class PaymentFailedCubit extends Cubit<PaymentFailedState> {
  final GetPaymentFailedUsecase _getPaymentFailed;

  PaymentFailedCubit({required GetPaymentFailedUsecase getPaymentFailed})
      : _getPaymentFailed = getPaymentFailed,
        super(PaymentFailedState.initial());

  Future<void> load(PaymentFailedRequest? request) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final info = await _getPaymentFailed(request);
      emit(state.copyWith(isLoading: false, info: info));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không tải được trạng thái thanh toán: $e',
      ));
    }
  }
}
