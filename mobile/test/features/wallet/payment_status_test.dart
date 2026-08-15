import 'package:flutter_test/flutter_test.dart';

import 'package:locker_mobile/features/wallet/domain/entities/payment_status.dart';

void main() {
  group('PaymentStatus enum', () {
    test('parses int values matching backend PaymentStatus enum', () {
      // Backend serializes PaymentStatus as int (no JsonStringEnumConverter).
      // From backend/src/Locker.Backend/.../PaymentStatus.cs:
      //   0 = Pending, 1 = Completed, 2 = Failed, 3 = Cancelled, 4 = Refunded
      expect(PaymentStatus.fromInt(0), PaymentStatus.pending);
      expect(PaymentStatus.fromInt(1), PaymentStatus.completed);
      expect(PaymentStatus.fromInt(2), PaymentStatus.failed);
      expect(PaymentStatus.fromInt(3), PaymentStatus.cancelled);
      expect(PaymentStatus.fromInt(4), PaymentStatus.refunded);
    });

    test('parses string values matching SignalR PaymentStatusChanged payload', () {
      // SignalR event payload uses .ToString() so we get string values.
      expect(PaymentStatus.fromString('Pending'), PaymentStatus.pending);
      expect(PaymentStatus.fromString('Completed'), PaymentStatus.completed);
      expect(PaymentStatus.fromString('Failed'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('Cancelled'), PaymentStatus.cancelled);
      expect(PaymentStatus.fromString('Refunded'), PaymentStatus.refunded);
    });

    test('isTerminal returns true for non-pending statuses', () {
      expect(PaymentStatus.pending.isTerminal, isFalse);
      expect(PaymentStatus.completed.isTerminal, isTrue);
      expect(PaymentStatus.failed.isTerminal, isTrue);
      expect(PaymentStatus.cancelled.isTerminal, isTrue);
      expect(PaymentStatus.refunded.isTerminal, isTrue);
    });

    test('isSuccess returns true only for completed', () {
      expect(PaymentStatus.completed.isSuccess, isTrue);
      expect(PaymentStatus.pending.isSuccess, isFalse);
      expect(PaymentStatus.failed.isSuccess, isFalse);
      expect(PaymentStatus.cancelled.isSuccess, isFalse);
      expect(PaymentStatus.refunded.isSuccess, isFalse);
    });

    test('throws on unknown int', () {
      expect(() => PaymentStatus.fromInt(99), throwsFormatException);
      expect(() => PaymentStatus.fromInt(-1), throwsFormatException);
    });

    test('throws on unknown string', () {
      expect(() => PaymentStatus.fromString('unknown'), throwsFormatException);
      expect(() => PaymentStatus.fromString('pending'), throwsFormatException);
      // String match is case-sensitive: backend .ToString() returns PascalCase.
    });
  });

  group('PaymentStatusResponse', () {
    test('parses full GET /payments/{id} payload (status as int)', () {
      final json = {
        'id': 'pay-uuid-123',
        'bookingId': 'booking-uuid',
        'userId': 'user-uuid',
        'amount': 200000,
        'status': 1, // int
        'method': 'sepay',
        'transactionId': 'TXN-001',
        'createdAt': '2026-08-15T10:00:00Z',
        'paidAt': '2026-08-15T10:05:00Z',
      };

      final response = PaymentStatusResponse.fromJson(json);

      expect(response.id, 'pay-uuid-123');
      expect(response.amount, 200000);
      expect(response.status, PaymentStatus.completed);
      expect(response.method, 'sepay');
      expect(response.transactionId, 'TXN-001');
      expect(response.paidAt, DateTime.utc(2026, 8, 15, 10, 5, 0));
    });

    test('paidAt can be null when not yet paid', () {
      final json = {
        'id': 'pay-uuid',
        'amount': 50000,
        'status': 0,
        'method': 'sepay',
      };

      final response = PaymentStatusResponse.fromJson(json);

      expect(response.paidAt, isNull);
      expect(response.status, PaymentStatus.pending);
    });
  });
}
