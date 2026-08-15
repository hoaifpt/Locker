import 'package:flutter_test/flutter_test.dart';
import 'package:locker_mobile/features/wallet/domain/entities/sepay_init_response.dart';

void main() {
  group('SepayInitResponse', () {
    test('parses full backend payload with all 5 fields', () {
      // Backend response shape (verified against web SepayInitResponse interface):
      //   { paymentId, paymentUrl, amount, sepayCode, expiresAt }
      final json = {
        'paymentId': 'pay_abc123',
        'paymentUrl': 'https://qr.sepay.vn/img?bank=TPBank&acc=...',
        'amount': 200000,
        'sepayCode': 'TOPUP XYZ789',
        'expiresAt': '2026-08-15T12:30:00Z',
      };

      final response = SepayInitResponse.fromJson(json);

      expect(response.paymentId, 'pay_abc123');
      expect(response.paymentUrl, 'https://qr.sepay.vn/img?bank=TPBank&acc=...');
      expect(response.amount, 200000);
      expect(response.sepayCode, 'TOPUP XYZ789');
      expect(response.expiresAt, DateTime.utc(2026, 8, 15, 12, 30, 0));
    });

    test('amount is parsed as int even when backend sends number-as-double', () {
      final json = {
        'paymentId': 'pay_xyz',
        'paymentUrl': 'https://qr.sepay.vn/img',
        'amount': 100000.0,
        'sepayCode': 'CODE123',
        'expiresAt': '2026-01-01T00:00:00Z',
      };

      final response = SepayInitResponse.fromJson(json);

      expect(response.amount, 100000);
      expect(response.amount, isA<int>());
    });

    test('throws on missing paymentId', () {
      expect(
        () => SepayInitResponse.fromJson({
          'paymentUrl': 'https://qr.sepay.vn/img',
          'amount': 100000,
          'sepayCode': 'CODE123',
          'expiresAt': '2026-01-01T00:00:00Z',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
