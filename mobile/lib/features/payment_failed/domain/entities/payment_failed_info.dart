class PaymentFailedRequest {
  final int amount;
  final String paymentMethod;
  final String? lockerHub;
  final String? reason;
  final String? referenceCode;

  const PaymentFailedRequest({
    required this.amount,
    required this.paymentMethod,
    this.lockerHub,
    this.reason,
    this.referenceCode,
  });
}

class PaymentFailedInfo {
  final int amount;
  final String paymentMethod;
  final String lockerHub;
  final String reason;
  final String referenceCode;
  final String title;
  final String message;

  const PaymentFailedInfo({
    required this.amount,
    required this.paymentMethod,
    required this.lockerHub,
    required this.reason,
    required this.referenceCode,
    required this.title,
    required this.message,
  });
}
