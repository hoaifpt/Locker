import 'package:flutter_test/flutter_test.dart';

import 'package:locker_mobile/features/wallet/domain/entities/sepay_cancel_response.dart';

void main() {
  group('SepayCancelResponse', () {
    test('parses success response with cancelled newStatus', () {
      // Backend SepayCancelTopUpResponse (camelCase JSON):
      //   { success: true, message: "...", newStatus: "Cancelled", paymentId: "guid" }
      final json = {
        'success': true,
        'message': 'Top-up cancelled.',
        'newStatus': 'Cancelled',
        'paymentId': 'pay-uuid-456',
      };

      final response = SepayCancelResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, 'Top-up cancelled.');
      expect(response.newStatus, 'Cancelled');
      expect(response.paymentId, 'pay-uuid-456');
    });

    test('parses failure response (success=false, newStatus already terminal)', () {
      final json = {
        'success': false,
        'message': 'Payment already completed.',
        'newStatus': 'Completed',
        'paymentId': 'pay-uuid-789',
      };

      final response = SepayCancelResponse.fromJson(json);

      expect(response.success, isFalse);
      expect(response.newStatus, 'Completed');
    });

    test('missing newStatus defaults to null', () {
      final json = {
        'success': false,
        'message': 'Unknown error',
      };

      final response = SepayCancelResponse.fromJson(json);

      expect(response.newStatus, isNull);
      expect(response.paymentId, isNull);
    });
  });
}
