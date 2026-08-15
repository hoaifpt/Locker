/// Payment status enum that matches the backend `PaymentStatus` C# enum
/// (verified from `backend/src/Locker.Backend.Application/Common/PaymentStatus.cs`).
///
/// The backend serializes this enum as an **integer** in REST responses
/// (no `JsonStringEnumConverter` registered) but as a **string** in the
/// SignalR `PaymentStatusChanged` event payload (uses `Status.ToString()`).
/// Use [fromInt] and [fromString] respectively.
enum PaymentStatus {
  pending,
  completed,
  failed,
  cancelled,
  refunded;

  bool get isTerminal =>
      this != PaymentStatus.pending;

  bool get isSuccess => this == PaymentStatus.completed;

  static PaymentStatus fromInt(int value) {
    switch (value) {
      case 0:
        return PaymentStatus.pending;
      case 1:
        return PaymentStatus.completed;
      case 2:
        return PaymentStatus.failed;
      case 3:
        return PaymentStatus.cancelled;
      case 4:
        return PaymentStatus.refunded;
      default:
        throw FormatException('Unknown PaymentStatus int: $value');
    }
  }

  /// Strict case-sensitive match. Backend `payment.Status.ToString()` returns
  /// PascalCase ("Pending"/"Completed"/...), NOT lowercase.
  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'Pending':
        return PaymentStatus.pending;
      case 'Completed':
        return PaymentStatus.completed;
      case 'Failed':
        return PaymentStatus.failed;
      case 'Cancelled':
        return PaymentStatus.cancelled;
      case 'Refunded':
        return PaymentStatus.refunded;
      default:
        throw FormatException('Unknown PaymentStatus string: "$value"');
    }
  }
}

/// Response from `GET /api/payments/{id}`.
///
/// `status` is the **integer** form of [PaymentStatus] (backend uses
/// default System.Text.Json enum serialization as int).
class PaymentStatusResponse {
  final String id;
  final String? bookingId;
  final String? userId;
  final int amount;
  final PaymentStatus status;
  final String? method;
  final String? transactionId;
  final DateTime? createdAt;
  final DateTime? paidAt;

  const PaymentStatusResponse({
    required this.id,
    required this.amount,
    required this.status,
    this.bookingId,
    this.userId,
    this.method,
    this.transactionId,
    this.createdAt,
    this.paidAt,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final status = rawStatus is int
        ? PaymentStatus.fromInt(rawStatus)
        : rawStatus is String
            ? PaymentStatus.fromString(rawStatus)
            : (throw FormatException(
                'PaymentStatusResponse.fromJson: status must be int or string, '
                'got ${rawStatus.runtimeType}',
              ));
    return PaymentStatusResponse(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      status: status,
      bookingId: json['bookingId'] as String?,
      userId: json['userId'] as String?,
      method: json['method'] as String?,
      transactionId: json['transactionId'] as String?,
      createdAt: _parseDate(json['createdAt']),
      paidAt: _parseDate(json['paidAt']),
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return DateTime.parse(raw).toUtc();
    throw FormatException('Expected ISO8601 date string, got ${raw.runtimeType}');
  }
}
