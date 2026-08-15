import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../domain/services/payment_realtime_service.dart';

/// Real SignalR-backed implementation that connects to the backend's
/// `/hubs/notifications` hub and forwards `PaymentStatusChanged` events.
///
/// Mirrors the web `createPaymentRealtimeConnection`
/// (`web/src/features/wallet/api/paymentRealtime.ts`):
/// - token via `?access_token=<jwt>` query string (required for WebSocket frames)
/// - auto-reconnect with the same backoff schedule
/// - no client → server invocations (the hub is server-push only)
class SignalRPaymentRealtimeService implements IPaymentRealtimeService {
  /// Build the absolute hub URL. Backend hub is configured in
  /// `Program.cs`: `app.MapHub<NotificationHub>("/hubs/notifications")`.
  ///
  /// [apiBaseUrl] is e.g. `https://api.hoaitran.online/api`. We strip the
  /// trailing `/api` (if any) and append `/hubs/notifications`.
  final String hubUrl;

  /// Token provider — must return the current JWT access token (without
  /// the "Bearer " prefix). Called every time the connection is opened
  /// so we always send the freshest token after refresh.
  final Future<String?> Function() tokenProvider;

  HubConnection? _connection;
  String? _currentPaymentId;
  bool _connected = false;

  SignalRPaymentRealtimeService({
    required this.hubUrl,
    required this.tokenProvider,
  });

  @override
  bool get isConnected => _connected;

  @override
  Future<void> start({
    required String paymentId,
    required void Function(PaymentStatusChangedPayload payload) onEvent,
  }) async {
    // If we already have a connection for the same paymentId, no-op.
    if (_connection != null && _currentPaymentId == paymentId) return;
    // Different payment → tear down first.
    if (_connection != null && _currentPaymentId != paymentId) {
      await stop();
    }

    _currentPaymentId = paymentId;
    final token = await tokenProvider();
    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token ?? '',
          ),
        )
        .withAutomaticReconnect(retryDelays: const [
          0,
          2000,
          5000,
          10000,
          30000,
        ])
        .build();

    _connection!.on(
      'PaymentStatusChanged',
      (List<Object?>? args) {
        if (args == null || args.isEmpty) return;
        final raw = args.first;
        if (raw is! Map) return;
        try {
          final json = Map<String, dynamic>.from(raw);
          final payload = PaymentStatusChangedPayload.fromJson(json);
          // Defence-in-depth: ignore events for other paymentIds.
          if (payload.paymentId == _currentPaymentId) {
            onEvent(payload);
          }
        } catch (_) {
          // Bad payload — skip silently; logged upstream if needed.
        }
      },
    );

    _connection!.onreconnecting((
      {Exception? error,
    }) =>
        _connected = false);
    _connection!.onreconnected((
      {String? connectionId,
    }) =>
        _connected = true);
    _connection!.onclose(({
      Exception? error,
    }) =>
        _connected = false);

    try {
      await _connection!.start();
      _connected = true;
    } catch (_) {
      _connected = false;
      // Don't rethrow — polling will pick up the slack.
    }
  }

  @override
  Future<void> stop() async {
    final conn = _connection;
    _connection = null;
    _currentPaymentId = null;
    _connected = false;
    if (conn == null) return;
    try {
      await conn.stop();
    } catch (_) {
      // best-effort
    }
  }
}
