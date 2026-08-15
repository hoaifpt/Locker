import 'dart:async';

import 'package:locker_mobile/features/wallet/domain/entities/payment_status.dart';

/// Server-pushed payload of the SignalR `PaymentStatusChanged` event.
///
/// Verified against backend PaymentStatusChangedEvent
/// (`backend/.../PaymentStatusChangedEvent.cs`):
///   { paymentId: guid, amount: decimal, status: string (PascalCase),
///     paidAt: ISO8601 string|null, transactionId: string|null }
class PaymentStatusChangedPayload {
  final String paymentId;
  final int amount;
  final PaymentStatus status;
  final DateTime? paidAt;
  final String? transactionId;

  const PaymentStatusChangedPayload({
    required this.paymentId,
    required this.amount,
    required this.status,
    this.paidAt,
    this.transactionId,
  });

  factory PaymentStatusChangedPayload.fromJson(Map<String, dynamic> json) {
    return PaymentStatusChangedPayload(
      paymentId: json['paymentId'] as String,
      amount: (json['amount'] as num).toInt(),
      status: PaymentStatus.fromString(json['status'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String).toUtc(),
      transactionId: json['transactionId'] as String?,
    );
  }
}

/// Abstract realtime channel so cubit tests can inject a fake without
/// bringing in the real signalr_client dependency.
///
/// Only events for the supplied `paymentId` are emitted downstream —
/// impls filter before forwarding.
abstract class IPaymentRealtimeService {
  /// Starts the underlying SignalR connection and subscribes to
  /// `PaymentStatusChanged`. `onEvent` is invoked only when
  /// `payload.paymentId == paymentId`.
  Future<void> start({
    required String paymentId,
    required void Function(PaymentStatusChangedPayload payload) onEvent,
  });

  Future<void> stop();

  bool get isConnected;
}

class NoopPaymentRealtimeService implements IPaymentRealtimeService {
  @override
  Future<void> start({
    required String paymentId,
    required void Function(PaymentStatusChangedPayload payload) onEvent,
  }) async {}

  @override
  Future<void> stop() async {}

  @override
  bool get isConnected => false;
}
