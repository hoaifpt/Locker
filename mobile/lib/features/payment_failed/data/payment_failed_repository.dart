import '../domain/entities/payment_failed_info.dart';
import '../domain/repositories/i_payment_failed_repository.dart';
import 'models/payment_failed_info_model.dart';

class PaymentFailedRepository implements IPaymentFailedRepository {
  @override
  Future<PaymentFailedInfo> getPaymentFailedInfo(
      PaymentFailedRequest? request) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return PaymentFailedInfoModel.fromJson({
      'amount': request?.amount ?? 17000,
      'paymentMethod': request?.paymentMethod ?? 'Ví E-BOX',
      'lockerHub': request?.lockerHub ?? 'Crescent Mall, Hub 04',
      'reason': request?.reason ?? 'Không thể xác thực giao dịch',
      'referenceCode': request?.referenceCode ?? 'PAY-FAILED-0001',
      'title': 'Thanh toán thất bại',
      'message':
          'Chúng tôi không thể xử lý giao dịch của bạn. Vui lòng thử lại hoặc đổi phương thức thanh toán.',
    });
  }
}
