enum PaymentResultStatus { success, failed, cancelled, expired, pending }

class PaymentResultRequest {
  const PaymentResultRequest({
    required this.status,
    required this.amount,
    required this.referenceCode,
    this.orderCode,
    this.paymentMethod,
    this.lockerHub,
    this.message,
  });

  final PaymentResultStatus status;
  final int amount;
  final String referenceCode;
  final String? orderCode;
  final String? paymentMethod;
  final String? lockerHub;
  final String? message;
}
