import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locker_mobile/core/network/api_client.dart';
import 'package:locker_mobile/features/wallet/data/wallet_repository.dart';

/// Test-only adapter that wraps ApiClient + Dio with an HTTP mock interceptor
/// so we can assert exact request paths/URLs without touching the network.
class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    // Drain the request stream so Dio doesn't complain about an
    // unconsumed body.
    if (requestStream != null) {
      await requestStream.drain();
    }
    return _handler(options);
  }
}

ResponseBody _okJson(Map<String, dynamic> data) {
  final encoded = utf8.encode(jsonEncode(data));
  return ResponseBody.fromBytes(
    encoded,
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

void main() {
  late WalletRepository repository;
  late List<RequestOptions> capturedRequests;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    capturedRequests = [];

    // Replace the singleton's Dio adapter BEFORE the repo runs any request
    // so we can intercept the request path Dio would send on the wire.
    final api = ApiClient();
    api.client.httpClientAdapter = _MockAdapter((options) async {
      capturedRequests.add(options);
      return _okJson({
        'paymentId': 'pay_test_1',
        'paymentUrl': 'https://qr.sepay.vn/img?test=1',
        'amount': 100000,
        'sepayCode': 'TOPUP TEST',
        'expiresAt': '2026-08-15T12:30:00Z',
      });
    });

    repository = WalletRepository();
  });

  group('WalletRepository.initSePayTopUp', () {
    test('POSTs to /wallet/top-up/sepay/init with amount body', () async {
      final response = await repository.initSePayTopUp(100000);

      expect(capturedRequests, hasLength(1));
      final req = capturedRequests.single;
      expect(req.method, 'POST');
      expect(req.path, '/wallet/top-up/sepay/init');
      expect(req.data, {'amount': 100000});

      // Returned object must expose all 5 backend fields, not just the URL.
      expect(response.paymentId, 'pay_test_1');
      expect(response.paymentUrl, 'https://qr.sepay.vn/img?test=1');
      expect(response.amount, 100000);
      expect(response.sepayCode, 'TOPUP TEST');
      expect(response.expiresAt, DateTime.utc(2026, 8, 15, 12, 30, 0));
    });

    test('does NOT call /wallet/top-up/sepay/init twice', () async {
      await repository.initSePayTopUp(50000);
      await repository.initSePayTopUp(200000);

      expect(capturedRequests, hasLength(2));
      expect(
        capturedRequests.map((r) => r.path).toList(),
        ['/wallet/top-up/sepay/init', '/wallet/top-up/sepay/init'],
      );
    });
  });

  group('WalletRepository.transfer', () {
    test('POSTs to /wallet/transfer with exactly ONE base URL (no double-prepend)', () async {
      await repository.transfer('user-42', 50000);

      expect(capturedRequests, hasLength(1));
      final req = capturedRequests.single;
      expect(req.method, 'POST');
      // The previous bug concatenated apiBaseUrl + endpoint manually,
      // producing "https://api.hoaitran.online/apihttps://api.hoaitran.online/api/wallet/transfer".
      // After the fix, Dio (with baseUrl already set) must see path = "/wallet/transfer"
      // exactly once. We assert the literal path string here.
      expect(req.path, '/wallet/transfer');
      expect(req.data, {'receiverId': 'user-42', 'amount': 50000});
    });

    test('does not contain "apiapi" substring (regression for double-base bug)', () async {
      await repository.transfer('user-42', 50000);

      final req = capturedRequests.single;
      // The previous bug produced URLs containing "apiapi" because
      // ${apiBaseUrl}${apiBaseUrl} was concatenated.
      expect(req.path.contains('apiapi'), isFalse,
          reason: 'Double-base URL bug regressed — path = "${req.path}"');
    });
  });
}
