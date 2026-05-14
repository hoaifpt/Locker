import '../entities/payment_success_info.dart';

abstract class IPaymentSuccessRepository {
  Future<PaymentSuccessInfo> getPaymentSuccessInfo(
      PaymentSuccessRequest? request);
}
