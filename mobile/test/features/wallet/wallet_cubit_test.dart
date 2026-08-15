import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locker_mobile/features/wallet/domain/entities/payment_status.dart';
import 'package:locker_mobile/features/wallet/domain/entities/sepay_cancel_response.dart';
import 'package:locker_mobile/features/wallet/domain/entities/sepay_init_response.dart';
import 'package:locker_mobile/features/wallet/domain/entities/wallet_overview.dart';
import 'package:locker_mobile/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:locker_mobile/features/wallet/domain/repositories/i_wallet_repository.dart';
import 'package:locker_mobile/features/wallet/domain/services/payment_realtime_service.dart';
import 'package:locker_mobile/features/wallet/domain/usecases/get_wallet_overview_usecase.dart';
import 'package:locker_mobile/features/wallet/presentation/controllers/wallet_cubit.dart';
import 'package:locker_mobile/features/wallet/presentation/controllers/wallet_state.dart';

/// Hand-rolled fake repository (no mocktail dependency).
/// Records every call so tests can assert what was sent downstream.
class _FakeWalletRepository implements IWalletRepository {
  SepayInitResponse? sepayResponse;
  Object? sepayError;
  Completer<SepayInitResponse>? pendingCompleter;

  PaymentStatusResponse? statusResponse;
  Object? statusError;

  SepayCancelResponse? cancelResponse;
  Object? cancelError;
  final List<String> statusCalls = [];
  final List<String> cancelCalls = [];

  WalletOverview? nextOverview;

  final List<double> initCalls = [];

  @override
  Future<SepayInitResponse> initSePayTopUp(double amount) async {
    initCalls.add(amount);
    if (pendingCompleter != null) return pendingCompleter!.future;
    if (sepayError != null) throw sepayError!;
    if (sepayResponse == null) {
      throw StateError('sepayResponse not configured in test');
    }
    return sepayResponse!;
  }

  @override
  Future<PaymentStatusResponse> checkPaymentStatus(String paymentId) async {
    statusCalls.add(paymentId);
    if (statusError != null) throw statusError!;
    return statusResponse ?? _notConfigured<PaymentStatusResponse>('statusResponse');
  }

  @override
  Future<SepayCancelResponse> cancelSepayTopUp(String paymentId) async {
    cancelCalls.add(paymentId);
    if (cancelError != null) throw cancelError!;
    return cancelResponse ?? _notConfigured<SepayCancelResponse>('cancelResponse');
  }

  @override
  Future<WalletOverview> getWalletOverview() async =>
      nextOverview ?? _notConfigured<WalletOverview>('nextOverview');

  // Unused in these tests:
  @override
  Future<List<WalletTransaction>> getTransactions() async =>
      throw UnimplementedError();
  @override
  Future<double> getBalance() async => throw UnimplementedError();
  @override
  Future<void> topUp(double amount) async => throw UnimplementedError();
  @override
  Future<void> transfer(String receiverId, double amount) async =>
      throw UnimplementedError();

  static T _notConfigured<T>(String name) =>
      throw StateError('$name not configured in test');
}

/// Fake realtime service that lets the test push events through a stream
/// instead of bringing in a real SignalR connection.
class _FakeRealtimeService implements IPaymentRealtimeService {
  final List<Map<String, dynamic>> startCalls = [];
  bool _connected = false;

  // Test pushes events here, the service fires `onEvent` with parsed payload.
  void Function(PaymentStatusChangedPayload payload)? _sink;

  @override
  Future<void> start({
    required String paymentId,
    required void Function(PaymentStatusChangedPayload payload) onEvent,
  }) async {
    startCalls.add({'paymentId': paymentId});
    _sink = onEvent;
    _connected = true;
  }

  @override
  Future<void> stop() async {
    _sink = null;
    _connected = false;
  }

  @override
  bool get isConnected => _connected;

  /// Test helper: push an event. `paymentId` filter is the cubit's job,
  /// not the service's — but the service still forwards everything.
  void push({
    required String paymentId,
    required PaymentStatus status,
    int amount = 0,
    DateTime? paidAt,
  }) {
    _sink?.call(PaymentStatusChangedPayload(
      paymentId: paymentId,
      amount: amount,
      status: status,
      paidAt: paidAt,
    ));
  }
}

void main() {
  late _FakeWalletRepository repo;
  late _FakeRealtimeService realtime;
  late WalletCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = _FakeWalletRepository();
    realtime = _FakeRealtimeService();
    cubit = WalletCubit(
      walletRepository: repo,
      getWalletOverview: GetWalletOverviewUseCase(repository: repo),
      realtimeService: realtime,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('WalletCubit.topUp', () {
    test('transitions to paying step and stores pendingPayment', () async {
      repo.sepayResponse = SepayInitResponse(
        paymentId: 'pay-1',
        paymentUrl: 'https://qr.sepay.vn/img?a',
        amount: 200000,
        sepayCode: 'TOPUP ABC',
        expiresAt: DateTime.utc(2026, 12, 31),
      );

      final result = await cubit.topUp(200000);

      expect(result, isNotNull);
      expect(cubit.state.topUpStep, TopUpStep.paying);
      expect(cubit.state.pendingPayment?.paymentId, 'pay-1');
      expect(cubit.state.pendingPayment?.sepayCode, 'TOPUP ABC');
      expect(cubit.state.paymentStatus, PaymentStatus.pending);
    });

    test('starts realtime subscription for new payment', () async {
      repo.sepayResponse = SepayInitResponse(
        paymentId: 'pay-2',
        paymentUrl: 'u',
        amount: 100000,
        sepayCode: 'c',
        expiresAt: DateTime.utc(2026, 1, 1),
      );

      await cubit.topUp(100000);

      expect(realtime.startCalls, hasLength(1));
      expect(realtime.startCalls.single['paymentId'], 'pay-2');
    });

    test('persists pending payment to shared_preferences', () async {
      repo.sepayResponse = SepayInitResponse(
        paymentId: 'pay-3',
        paymentUrl: 'u',
        amount: 100000,
        sepayCode: 'TOPUP XYZ',
        expiresAt: DateTime.utc(2099, 1, 1),
      );

      await cubit.topUp(100000);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('locker:pending-topup');
      expect(raw, isNotNull);
      final json = jsonDecode(raw!) as Map<String, dynamic>;
      expect(json['paymentId'], 'pay-3');
      expect(json['sepayCode'], 'TOPUP XYZ');
    });
  });

  group('WalletCubit realtime → state', () {
    test('PaymentStatusChanged(completed) transitions to success step',
        () async {
      repo.sepayResponse = SepayInitResponse(
        paymentId: 'pay-4',
        paymentUrl: 'u',
        amount: 200000,
        sepayCode: 'c',
        expiresAt: DateTime.utc(2099, 1, 1),
      );
      repo.nextOverview = const WalletOverview(
        balance: 500000,
        monthlyChange: 200000,
        points: 0,
        transactions: [],
      );

      await cubit.topUp(200000);

      realtime.push(
        paymentId: 'pay-4',
        status: PaymentStatus.completed,
        amount: 200000,
        paidAt: DateTime.utc(2026, 8, 15, 10, 5),
      );
      // Let cubit process async refreshWallet
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.paymentStatus, PaymentStatus.completed);
      expect(cubit.state.topUpStep, TopUpStep.success);
      expect(cubit.state.overview?.balance, 500000);
      // Cleanup: success clears pending payment but should also clear prefs
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locker:pending-topup'), isNull);
    });

    test('realtime event for different paymentId is ignored', () async {
      repo.sepayResponse = SepayInitResponse(
        paymentId: 'pay-5',
        paymentUrl: 'u',
        amount: 100000,
        sepayCode: 'c',
        expiresAt: DateTime.utc(2099, 1, 1),
      );
      await cubit.topUp(100000);

      realtime.push(
        paymentId: 'pay-other',
        status: PaymentStatus.completed,
      );
      await Future<void>.delayed(Duration.zero);

      // Should still be pending, not completed
      expect(cubit.state.paymentStatus, PaymentStatus.pending);
      expect(cubit.state.topUpStep, TopUpStep.paying);
    });
  });

  group('WalletCubit.cancelTopUp', () {
    test('calls repository, sets paymentStatus=cancelled, clears prefs', () async {
      repo.sepayResponse = SepayInitResponse(
        paymentId: 'pay-6',
        paymentUrl: 'u',
        amount: 100000,
        sepayCode: 'c',
        expiresAt: DateTime.utc(2099, 1, 1),
      );
      repo.cancelResponse = const SepayCancelResponse(
        success: true,
        message: 'Cancelled',
        newStatus: 'Cancelled',
        paymentId: 'pay-6',
      );
      await cubit.topUp(100000);

      await cubit.cancelTopUp();

      expect(repo.cancelCalls, ['pay-6']);
      expect(cubit.state.paymentStatus, PaymentStatus.cancelled);
      // After cancel, the wizard stays on the cancelled step so the user
      // can see the QR + "Tạo mã mới" CTA — mirrors web pattern.
      expect(cubit.state.topUpStep, TopUpStep.cancelled);
      expect(cubit.state.pendingPayment?.paymentId, 'pay-6');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locker:pending-topup'), isNull);
    });

    test('emits errorMessage when backend rejects', () async {
      repo.sepayResponse = SepayInitResponse(
        paymentId: 'pay-7',
        paymentUrl: 'u',
        amount: 100000,
        sepayCode: 'c',
        expiresAt: DateTime.utc(2099, 1, 1),
      );
      repo.cancelResponse = const SepayCancelResponse(
        success: false,
        message: 'Already completed',
        newStatus: 'Completed',
        paymentId: 'pay-7',
      );
      await cubit.topUp(100000);

      await cubit.cancelTopUp();

      expect(cubit.state.errorMessage, contains('Already completed'));
      expect(cubit.state.paymentStatus, PaymentStatus.pending);
    });
  });

  group('WalletCubit.restorePending', () {
    test('restores pending payment from prefs on init', () async {
      // Pre-seed prefs as if previous session left a pending top-up
      SharedPreferences.setMockInitialValues({
        'locker:pending-topup': jsonEncode({
          'paymentId': 'pay-restored',
          'paymentUrl': 'https://qr.sepay.vn/img?restored',
          'amount': 300000,
          'sepayCode': 'TOPUP RST',
          'expiresAt': DateTime.utc(2099, 1, 1).toIso8601String(),
        }),
      });

      // Build a fresh cubit so it reads the seeded prefs at construction
      final freshRepo = _FakeWalletRepository();
      final freshRealtime = _FakeRealtimeService();
      final restored = WalletCubit(
        walletRepository: freshRepo,
        getWalletOverview: GetWalletOverviewUseCase(repository: freshRepo),
        realtimeService: freshRealtime,
      );

      await restored.restorePending();

      expect(restored.state.topUpStep, TopUpStep.paying);
      expect(restored.state.pendingPayment?.paymentId, 'pay-restored');
      expect(restored.state.pendingPayment?.sepayCode, 'TOPUP RST');
      // Realtime re-subscribed for the restored paymentId
      expect(freshRealtime.startCalls.last['paymentId'], 'pay-restored');
    });

    test('does nothing when no pending payment in prefs', () async {
      await cubit.restorePending();
      expect(cubit.state.topUpStep, TopUpStep.idle);
      expect(cubit.state.pendingPayment, isNull);
      expect(realtime.startCalls, isEmpty);
    });

    test('clears expired pending payment on restore', () async {
      SharedPreferences.setMockInitialValues({
        'locker:pending-topup': jsonEncode({
          'paymentId': 'pay-expired',
          'paymentUrl': 'u',
          'amount': 100000,
          'sepayCode': 'c',
          'expiresAt':
              DateTime.utc(2000, 1, 1).toIso8601String(), // ancient past
        }),
      });

      final freshRepo = _FakeWalletRepository();
      final freshRealtime = _FakeRealtimeService();
      final restored = WalletCubit(
        walletRepository: freshRepo,
        getWalletOverview: GetWalletOverviewUseCase(repository: freshRepo),
        realtimeService: freshRealtime,
      );
      await restored.restorePending();

      expect(restored.state.topUpStep, TopUpStep.idle);
      expect(restored.state.pendingPayment, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locker:pending-topup'), isNull);
    });
  });

  group('WalletCubit.tickCountdown', () {
    test('updates countdownSeconds every second', () async {
      repo.sepayResponse = SepayInitResponse(
        paymentId: 'pay-cd',
        paymentUrl: 'u',
        amount: 100000,
        sepayCode: 'c',
        expiresAt: DateTime.now().toUtc().add(const Duration(seconds: 5)),
      );
      await cubit.topUp(100000);

      cubit.tickCountdown();
      expect(cubit.state.countdownSeconds, inInclusiveRange(0, 5));
    });
  });
}
