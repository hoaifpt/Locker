import '../entities/payment_failed_info.dart';
import '../repositories/i_payment_failed_repository.dart';

class GetPaymentFailedUsecase {
  final IPaymentFailedRepository _repository;

  GetPaymentFailedUsecase(this._repository);

  Future<PaymentFailedInfo> call(PaymentFailedRequest? request) {
    return _repository.getPaymentFailedInfo(request);
  }
}
