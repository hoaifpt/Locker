import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/payment_status.dart';
import '../../domain/entities/sepay_init_response.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../../domain/services/payment_realtime_service.dart';
import '../../domain/usecases/get_wallet_overview_usecase.dart';
import 'wallet_state.dart';

const String _kPendingPaymentPrefsKey = 'locker:pending-topup';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletOverviewUseCase _getWalletOverview;
  final IWalletRepository _walletRepository;
  final IPaymentRealtimeService _realtimeService;

  Timer? _countdownTimer;

  WalletCubit({
    required GetWalletOverviewUseCase getWalletOverview,
    required IWalletRepository walletRepository,
    required IPaymentRealtimeService realtimeService,
  }) : _getWalletOverview = getWalletOverview,
       _walletRepository = walletRepository,
       _realtimeService = realtimeService,
       super(WalletState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final overview = await _getWalletOverview();
      emit(state.copyWith(isLoading: false, overview: overview));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không tải được ví E-BOX: $e',
        ),
      );
    }
  }

  /// Starts a SePay top-up. On success, transitions to [TopUpStep.paying],
  /// stores the pending payment, persists to SharedPreferences (so we can
  /// resume after app kill), and starts the realtime subscription.
  Future<SepayInitResponse?> topUp(double amount) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final response = await _walletRepository.initSePayTopUp(amount);
      emit(
        state.copyWith(
          isLoading: false,
          topUpStep: TopUpStep.paying,
          pendingPayment: response,
          paymentStatus: PaymentStatus.pending,
        ),
      );
      await _persistPending(response);
      await _realtimeService.start(
        paymentId: response.paymentId,
        onEvent: _onRealtimeEvent,
      );
      _startCountdown();
      return response;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Khởi tạo thanh toán thất bại: $e',
        ),
      );
      return null;
    }
  }

  void _onRealtimeEvent(PaymentStatusChangedPayload payload) {
    final pending = state.pendingPayment;
    // Filter: only react to events for OUR paymentId (defence-in-depth —
    // impls should also filter, but we re-check at the consumer).
    if (pending == null || payload.paymentId != pending.paymentId) return;

    if (payload.status == PaymentStatus.completed) {
      _stopCountdown();
      emit(
        state.copyWith(
          paymentStatus: PaymentStatus.completed,
          topUpStep: TopUpStep.success,
          pendingPayment: null,
        ),
      );
      unawaited(_realtimeService.stop());
      unawaited(_clearPersistedPending());
      unawaited(_refreshOverview());
    } else if (payload.status.isTerminal) {
      _stopCountdown();
      if (payload.status == PaymentStatus.cancelled) {
        // Polling / SignalR caught up AFTER the user explicitly cancelled.
        // Keep pendingPayment so the overlay can show the QR + the
        // "Tạo mã mới" CTA, but make sure the step is cancelled too — the
        // user-confirmed cancel in `cancelTopUp` already set that, but a
        // race with polling could have left the step at `paying`.
        emit(
          state.copyWith(
            paymentStatus: PaymentStatus.cancelled,
            topUpStep: TopUpStep.cancelled,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            paymentStatus: payload.status,
            pendingPayment: null,
            errorMessage: 'Thanh toán thất bại.',
          ),
        );
      }
      unawaited(_realtimeService.stop());
      unawaited(_clearPersistedPending());
    }
    // For 'pending' or other in-flight statuses, do nothing — countdown
    // is still ticking.
  }

  Future<void> cancelTopUp() async {
    final pending = state.pendingPayment;
    if (pending == null) return;
    emit(state.copyWith(isCancelling: true));
    try {
      final response = await _walletRepository.cancelSepayTopUp(
        pending.paymentId,
      );
      if (response.success) {
        _stopCountdown();
        // Stop realtime but KEEP pendingPayment in state so the page can
        // render the cancelled overlay with the QR + bank info + a
        // "Tạo mã mới" CTA — mirrors web pattern (the user explicitly
        // cancelled this payment; we shouldn't pretend it never existed).
        unawaited(_realtimeService.stop());
        await _clearPersistedPending();
        emit(
          state.copyWith(
            isCancelling: false,
            paymentStatus: PaymentStatus.cancelled,
            topUpStep: TopUpStep.cancelled,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isCancelling: false,
            errorMessage:
                response.message.isNotEmpty
                    ? response.message
                    : 'Không thể huỷ thanh toán.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isCancelling: false,
          errorMessage: 'Không thể huỷ thanh toán: $e',
        ),
      );
    }
  }

  /// Resets the top-up wizard back to the amount-selection step, used by
  /// the "Tạo mã mới" CTA in the cancelled / expired / failed overlay.
  /// Mirrors web `handleCreateNew` in WalletPage.tsx.
  void createNewTopUp() {
    _stopCountdown();
    unawaited(_realtimeService.stop());
    emit(
      state.copyWith(
        topUpStep: TopUpStep.selectAmount,
        pendingPayment: null,
        paymentStatus: PaymentStatus.pending,
        countdownSeconds: 0,
        clearPendingPayment: true,
      ),
    );
  }

  /// Polls the current payment status via REST as a fallback when the
  /// realtime channel is unavailable or missed an event.
  Future<void> pollPaymentStatus() async {
    final pending = state.pendingPayment;
    if (pending == null) return;
    emit(state.copyWith(isPolling: true));
    try {
      final response = await _walletRepository.checkPaymentStatus(
        pending.paymentId,
      );
      emit(state.copyWith(isPolling: false));
      // Re-use the realtime handler with a synthesised payload so the
      // terminal-status logic stays in one place.
      _onRealtimeEvent(
        PaymentStatusChangedPayload(
          paymentId: pending.paymentId,
          amount: response.amount,
          status: response.status,
          paidAt: response.paidAt,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isPolling: false));
      // Silent — next poll will try again.
    }
  }

  /// Recomputes the countdown timer. Should be called on a 1s interval
  /// by the UI (mirrors the React useEffect in WalletPage).
  void tickCountdown() {
    final pending = state.pendingPayment;
    if (pending == null) return;
    final seconds = pending.expiresAt
        .difference(DateTime.now().toUtc())
        .inSeconds;
    final clamped = seconds < 0 ? 0 : seconds;
    if (clamped != state.countdownSeconds) {
      emit(state.copyWith(countdownSeconds: clamped));
    }
    if (clamped == 0) {
      _stopCountdown();
    }
  }

  void _startCountdown() {
    _stopCountdown();
    tickCountdown();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => tickCountdown(),
    );
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  Future<void> _refreshOverview() async {
    try {
      final overview = await _getWalletOverview();
      emit(state.copyWith(overview: overview));
    } catch (_) {
      // Silent — UI still shows the success screen.
    }
  }

  Future<void> _persistPending(SepayInitResponse r) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPendingPaymentPrefsKey,
      jsonEncode({
        'paymentId': r.paymentId,
        'paymentUrl': r.paymentUrl,
        'amount': r.amount,
        'sepayCode': r.sepayCode,
        'expiresAt': r.expiresAt.toIso8601String(),
      }),
    );
  }

  Future<void> _clearPersistedPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPendingPaymentPrefsKey);
  }

  /// Reads the persisted pending top-up (if any) and, if still valid,
  /// transitions to [TopUpStep.paying] + resumes the realtime channel.
  /// Call this once at app start (e.g. from the wallet page init).
  Future<void> restorePending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPendingPaymentPrefsKey);
    if (raw == null) return;

    Map<String, dynamic> json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      await prefs.remove(_kPendingPaymentPrefsKey);
      return;
    }

    final expiresAtRaw = json['expiresAt'] as String?;
    final expiresAt = expiresAtRaw == null
        ? null
        : DateTime.tryParse(expiresAtRaw)?.toUtc();
    if (expiresAt == null || expiresAt.isBefore(DateTime.now().toUtc())) {
      // Expired — clear and don't restore.
      await prefs.remove(_kPendingPaymentPrefsKey);
      return;
    }

    final pending = SepayInitResponse(
      paymentId: json['paymentId'] as String,
      paymentUrl: json['paymentUrl'] as String,
      amount: (json['amount'] as num).toInt(),
      sepayCode: json['sepayCode'] as String,
      expiresAt: expiresAt,
    );

    emit(
      state.copyWith(
        topUpStep: TopUpStep.paying,
        pendingPayment: pending,
        paymentStatus: PaymentStatus.pending,
      ),
    );
    _startCountdown();
    await _realtimeService.start(
      paymentId: pending.paymentId,
      onEvent: _onRealtimeEvent,
    );
  }

  /// Close all timers and realtime subscriptions when the cubit is
  /// disposed.
  @override
  Future<void> close() {
    _stopCountdown();
    unawaited(_realtimeService.stop());
    return super.close();
  }
}
