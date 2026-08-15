import '../../domain/entities/payment_status.dart';
import '../../domain/entities/sepay_init_response.dart';
import '../../domain/entities/wallet_overview.dart';

/// High-level phase of the top-up wizard. Mirrors web `TopupStep` in
/// `web/src/features/wallet/pages/WalletPage.tsx`.
enum TopUpStep { idle, selectAmount, paying, success }

class WalletState {
  final bool isLoading;
  final WalletOverview? overview;
  final String? errorMessage;

  // Top-up sub-state ---------------------------------------------------
  final TopUpStep topUpStep;
  final SepayInitResponse? pendingPayment;
  final PaymentStatus paymentStatus;
  final int countdownSeconds;
  final bool realtimeConnected;
  final bool isCancelling;
  final bool isPolling;

  const WalletState({
    required this.isLoading,
    this.overview,
    this.errorMessage,
    this.topUpStep = TopUpStep.idle,
    this.pendingPayment,
    this.paymentStatus = PaymentStatus.pending,
    this.countdownSeconds = 0,
    this.realtimeConnected = false,
    this.isCancelling = false,
    this.isPolling = false,
  });

  factory WalletState.initial() => const WalletState(isLoading: true);

  bool get hasPendingPayment =>
      pendingPayment != null &&
      paymentStatus == PaymentStatus.pending &&
      topUpStep == TopUpStep.paying;

  bool get paymentExpired =>
      hasPendingPayment &&
      pendingPayment!.expiresAt.isBefore(DateTime.now().toUtc());

  WalletState copyWith({
    bool? isLoading,
    WalletOverview? overview,
    String? errorMessage,
    bool clearError = false,
    TopUpStep? topUpStep,
    SepayInitResponse? pendingPayment,
    bool clearPendingPayment = false,
    PaymentStatus? paymentStatus,
    int? countdownSeconds,
    bool? realtimeConnected,
    bool? isCancelling,
    bool? isPolling,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      overview: overview ?? this.overview,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      topUpStep: topUpStep ?? this.topUpStep,
      pendingPayment:
          clearPendingPayment ? null : (pendingPayment ?? this.pendingPayment),
      paymentStatus: paymentStatus ?? this.paymentStatus,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      realtimeConnected: realtimeConnected ?? this.realtimeConnected,
      isCancelling: isCancelling ?? this.isCancelling,
      isPolling: isPolling ?? this.isPolling,
    );
  }
}
