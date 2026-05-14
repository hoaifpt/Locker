import '../entities/payment_success_info.dart';
import '../repositories/i_payment_success_repository.dart';

class GetPaymentSuccessUsecase {
  final IPaymentSuccessRepository _repository;

  GetPaymentSuccessUsecase(this._repository);

  Future<PaymentSuccessInfo> call(PaymentSuccessRequest? request) {
    return _repository.getPaymentSuccessInfo(request);
  }
}
