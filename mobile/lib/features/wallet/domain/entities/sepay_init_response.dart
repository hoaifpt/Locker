/// Response from `POST /wallet/top-up/sepay/init`.
///
/// Backend (verified against web `SepayInitResponse` interface in
/// `web/src/features/wallet/pages/WalletPage.tsx`) returns:
/// ```json
/// {
///   "paymentId":   "pay_...",
///   "paymentUrl":  "https://qr.sepay.vn/img?...",
///   "amount":      200000,
///   "sepayCode":   "TOPUP XYZ",
///   "expiresAt":   "2026-08-15T12:30:00Z"
/// }
/// ```
class SepayInitResponse {
  final String paymentId;
  final String paymentUrl;
  final int amount;
  final String sepayCode;
  final DateTime expiresAt;

  const SepayInitResponse({
    required this.paymentId,
    required this.paymentUrl,
    required this.amount,
    required this.sepayCode,
    required this.expiresAt,
  });

  factory SepayInitResponse.fromJson(Map<String, dynamic> json) {
    final paymentId = json['paymentId'];
    final paymentUrl = json['paymentUrl'];
    final sepayCode = json['sepayCode'];
    final expiresAt = json['expiresAt'];
    if (paymentId is! String ||
        paymentUrl is! String ||
        sepayCode is! String ||
        expiresAt is! String) {
      throw FormatException(
        'SepayInitResponse.fromJson: missing or wrong-typed required fields '
        '(paymentId, paymentUrl, sepayCode, expiresAt). Got types: '
        'paymentId=${paymentId.runtimeType}, '
        'paymentUrl=${paymentUrl.runtimeType}, '
        'sepayCode=${sepayCode.runtimeType}, '
        'expiresAt=${expiresAt.runtimeType}',
      );
    }
    final rawAmount = json['amount'];
    final amount = rawAmount is int
        ? rawAmount
        : rawAmount is double
            ? rawAmount.toInt()
            : (throw FormatException(
                'SepayInitResponse.fromJson: amount must be int or double, '
                'got ${rawAmount.runtimeType}',
              ));
    return SepayInitResponse(
      paymentId: paymentId,
      paymentUrl: paymentUrl,
      amount: amount,
      sepayCode: sepayCode,
      expiresAt: DateTime.parse(expiresAt).toUtc(),
    );
  }
}
