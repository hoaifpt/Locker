class PaymentSuccessRequest {
  final int paidAmount;
  final String orderCode;
  final String? lockerHub;
  final String? transactionId;
  final String? paymentMethod;

  const PaymentSuccessRequest({
    required this.paidAmount,
    required this.orderCode,
    this.lockerHub,
    this.transactionId,
    this.paymentMethod,
  });
}

class PaymentSuccessInfo {
  final int paidAmount;
  final String lockerHub;
  final String transactionId;
  final String orderCode;
  final String paymentMethod;
  final String title;
  final String message;

  const PaymentSuccessInfo({
    required this.paidAmount,
    required this.lockerHub,
    required this.transactionId,
    required this.orderCode,
    required this.paymentMethod,
    required this.title,
    required this.message,
  });
}
