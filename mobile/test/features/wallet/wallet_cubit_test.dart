import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:locker_mobile/features/wallet/domain/entities/sepay_init_response.dart';
import 'package:locker_mobile/features/wallet/domain/entities/wallet_overview.dart';
import 'package:locker_mobile/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:locker_mobile/features/wallet/domain/repositories/i_wallet_repository.dart';
import 'package:locker_mobile/features/wallet/domain/usecases/get_wallet_overview_usecase.dart';
import 'package:locker_mobile/features/wallet/presentation/controllers/wallet_cubit.dart';
import 'package:locker_mobile/features/wallet/presentation/controllers/wallet_state.dart';

/// Hand-rolled fake repository (no mocktail dependency).
/// Records every initSePayTopUp call and replays the configured response.
class _FakeWalletRepository implements IWalletRepository {
  SepayInitResponse? sepayResponse;
  Object? sepayError;
  Completer<SepayInitResponse>? pendingCompleter;
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

  // Unused in these tests:
  @override
  Future<WalletOverview> getWalletOverview() async => throw UnimplementedError();
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
}

void main() {
  late _FakeWalletRepository repo;
  late WalletCubit cubit;

  setUp(() {
    repo = _FakeWalletRepository();
    cubit = WalletCubit(
      walletRepository: repo,
      getWalletOverview: GetWalletOverviewUseCase(repository: repo),
    );
  });

  tearDown(() => cubit.close());

  test('topUp returns SepayInitResponse with full backend payload', () async {
    repo.sepayResponse = SepayInitResponse(
      paymentId: 'pay_cubit_1',
      paymentUrl: 'https://qr.sepay.vn/img?bank=TPBank',
      amount: 300000,
      sepayCode: 'TOPUP ABC',
      expiresAt: DateTime.utc(2026, 12, 31, 23, 59, 59),
    );

    final result = await cubit.topUp(300000);

    expect(result, isNotNull);
    expect(result!.paymentId, 'pay_cubit_1');
    expect(result.paymentUrl, 'https://qr.sepay.vn/img?bank=TPBank');
    expect(result.amount, 300000);
    expect(result.sepayCode, 'TOPUP ABC');
    expect(result.expiresAt, DateTime.utc(2026, 12, 31, 23, 59, 59));

    expect(repo.initCalls, [300000]);
  });

  test('topUp emits loading state while in flight', () async {
    repo.pendingCompleter = Completer<SepayInitResponse>();

    final future = cubit.topUp(100000);

    // Yield to event loop so the loading emit lands.
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isLoading, isTrue);

    repo.pendingCompleter!.complete(SepayInitResponse(
      paymentId: 'p',
      paymentUrl: 'u',
      amount: 100000,
      sepayCode: 'c',
      expiresAt: DateTime.utc(2026, 1, 1),
    ));
    await future;
    expect(cubit.state.isLoading, isFalse);
  });

  test('topUp emits errorMessage on failure and returns null', () async {
    repo.sepayError = Exception('boom');

    final result = await cubit.topUp(100000);

    expect(result, isNull);
    expect(cubit.state.errorMessage, contains('Khởi tạo thanh toán thất bại'));
    expect(cubit.state.isLoading, isFalse);
  });

  test('WalletState.initial() exposes isLoading=true and null overview', () {
    final state = WalletState.initial();
    expect(state.isLoading, isTrue);
    expect(state.overview, isNull);
    expect(state.errorMessage, isNull);
    expect(WalletOverview, isNotNull);
  });
}
