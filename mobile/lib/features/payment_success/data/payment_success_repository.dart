import '../domain/entities/payment_success_info.dart';
import '../domain/repositories/i_payment_success_repository.dart';

class PaymentSuccessRepository implements IPaymentSuccessRepository {
  @override
  Future<PaymentSuccessInfo> getPaymentSuccessInfo(
      PaymentSuccessRequest? request) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final orderCode = request?.orderCode ?? 'EBOX-00000';
    return PaymentSuccessInfo(
      paidAmount: request?.paidAmount ?? 0,
      lockerHub: request?.lockerHub ?? 'Crescent Mall, Hub 04',
      transactionId: request?.transactionId ?? 'TXN-$orderCode',
      orderCode: orderCode,
      paymentMethod: request?.paymentMethod ?? 'Ví E-BOX',
      title: 'Thanh toán thành công!',
      message:
          'Ngăn chứa đồ của bạn đã được đặt chỗ an toàn. Chúng tôi sẽ thông báo cho bạn khi gói hàng đến.',
    );
  }
}
