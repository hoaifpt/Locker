import '../../domain/entities/payment_failed_info.dart';

class PaymentFailedInfoModel extends PaymentFailedInfo {
  const PaymentFailedInfoModel({
    required super.amount,
    required super.paymentMethod,
    required super.lockerHub,
    required super.reason,
    required super.referenceCode,
    required super.title,
    required super.message,
  });

  factory PaymentFailedInfoModel.fromJson(Map<String, dynamic> json) {
    return PaymentFailedInfoModel(
      amount: json['amount'] as int? ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? 'Ví E-BOX',
      lockerHub: json['lockerHub'] as String? ?? 'Crescent Mall, Hub 04',
      reason: json['reason'] as String? ?? 'Không thể xác thực giao dịch',
      referenceCode: json['referenceCode'] as String? ?? 'PAY-FAILED-0001',
      title: json['title'] as String? ?? 'Thanh toán thất bại',
      message: json['message'] as String? ??
          'Chúng tôi không thể xử lý giao dịch của bạn. Vui lòng thử lại hoặc đổi phương thức thanh toán.',
    );
  }
}
