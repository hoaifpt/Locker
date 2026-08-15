/// Response from `POST /api/wallet/top-up/sepay/cancel`.
///
/// Verified against backend `SepayCancelTopUpResponse`
/// (`backend/src/Locker.Backend.Application/Features/Wallet/.../SepayCancelTopUpResponse.cs`):
///   { success: bool, message: string, newStatus: string? (PascalCase enum name),
///     paymentId: string? (guid) }
class SepayCancelResponse {
  final bool success;
  final String message;
  final String? newStatus;
  final String? paymentId;

  const SepayCancelResponse({
    required this.success,
    required this.message,
    this.newStatus,
    this.paymentId,
  });

  factory SepayCancelResponse.fromJson(Map<String, dynamic> json) {
    return SepayCancelResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      newStatus: json['newStatus'] as String?,
      paymentId: json['paymentId'] as String?,
    );
  }
}
