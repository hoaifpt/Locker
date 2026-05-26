import '../entities/payment_failed_info.dart';

abstract class IPaymentFailedRepository {
  Future<PaymentFailedInfo> getPaymentFailedInfo(PaymentFailedRequest? request);
}
