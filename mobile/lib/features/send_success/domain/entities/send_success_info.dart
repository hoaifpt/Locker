class SendSuccessRequest {
  final String? lockerHub;
  final String? pin; // e.g. "882109"
  final int? amount;
  final String? orderCode;

  const SendSuccessRequest(
      {this.lockerHub, this.pin, this.amount, this.orderCode});
}

class SendSuccessInfo {
  final String title;
  final String message;
  final String lockerHub;
  final String pin;
  final int? amount;
  final String? orderCode;

  const SendSuccessInfo({
    required this.title,
    required this.message,
    required this.lockerHub,
    required this.pin,
    this.amount,
    this.orderCode,
  });
}
