import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_status.dart';
import '../../domain/entities/sepay_init_response.dart';
import '../../utils/currency.dart';
import '../controllers/wallet_cubit.dart';
import '../controllers/wallet_state.dart';
import '../../widgets/payment_status_badge.dart';

/// Web-styled top-up page. Layout mirrors the inline stepper in
/// `web/src/features/wallet/pages/WalletPage.tsx` (lines 577-1170):
///   - Slate-on-white stepper header with payment step indicator
///   - 2-col QR + instructions when paying (stacked on mobile)
///   - Slate "Quét mã VietQR" QR card with status badge, countdown, cancel
///   - Receiver info card (bank / account / owner / amount)
///   - On success: emerald hero + transaction detail card with copy CTA
///   - On cancel: keep the QR visible with a "Đã huỷ" badge + "Tạo mã mới"
class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  Timer? _countdownTimer;
  Timer? _pollingTimer;

  // Web parity constants ---------------------------------------------------
  static const _kBankAccount = '84519828888';
  static const _kBankName = 'TPBank';
  static const _kBankOwner = 'PHAM DUC HUNG';
  static const _kPresetAmounts = [
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
  ];
  static const _kMinAmount = 10000;

  /// Sentinel epoch used when the cancelled state exists without a
  /// pendingPayment (defensive fallback only). Far in the future so the
  /// countdown shows zeros immediately.
  static final DateTime _kEpoch = DateTime.utc(2099, 12, 31, 23, 59, 59);

  @override
  void dispose() {
    _stopTimers();
    _amountController.dispose();
    super.dispose();
  }

  void _startPayingTimers(WalletCubit cubit) {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      cubit.tickCountdown();
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      cubit.pollPaymentStatus();
    });
  }

  void _stopTimers() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    _countdownTimer = null;
    _pollingTimer = null;
  }

  Future<void> _handleTopUp() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount < _kMinAmount) {
      _showSnackBar('Số tiền tối thiểu là 10.000 ₫');
      return;
    }
    final cubit = context.read<WalletCubit>();
    final sepayResponse = await cubit.topUp(amount.toDouble());
    if (!mounted) return;
    if (sepayResponse == null) {
      final err = cubit.state.errorMessage ?? 'Khởi tạo thanh toán thất bại';
      _showSnackBar(err);
    }
  }

  Future<void> _confirmCancel() async {
    final cubit = context.read<WalletCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 8),
            Text(
              'Huỷ thanh toán này?',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: const Text(
          'Nếu bạn đã chuyển khoản, vui lòng liên hệ hỗ trợ để được hoàn tiền. Hệ thống không tự hoàn tiền tự động.',
          style: TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
            ),
            child: const Text('Tiếp tục thanh toán'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Vẫn huỷ'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // Stop the page's polling timer BEFORE the cubit's await so an
    // in-flight poll() can't beat `cancelTopUp` to the state machine and
    // null out `pendingPayment` while the UI is mid-rebuild.
    _stopTimers();
    await cubit.cancelTopUp();
  }

  Future<void> _copySepayCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    _showSnackBar('Đã sao chép mã $code');
  }

  Future<void> _copyAccount() async {
    await Clipboard.setData(const ClipboardData(text: _kBankAccount));
    if (!mounted) return;
    _showSnackBar('Đã sao chép số tài khoản');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatTimestamp(DateTime? iso) {
    final d = iso ?? DateTime.now();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$hh:$mm:$ss · $dd/$month/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F8),
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nạp tiền vào ví',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: BlocConsumer<WalletCubit, WalletState>(
        listenWhen: (prev, next) =>
            prev.topUpStep != next.topUpStep ||
            prev.errorMessage != next.errorMessage,
        listener: (context, state) {
          final cubit = context.read<WalletCubit>();
          if (state.topUpStep == TopUpStep.paying) {
            _startPayingTimers(cubit);
          } else if (state.topUpStep == TopUpStep.idle ||
              state.topUpStep == TopUpStep.selectAmount) {
            _stopTimers();
          } else if (state.topUpStep == TopUpStep.success) {
            _stopTimers();
          } else if (state.topUpStep == TopUpStep.cancelled) {
            _stopTimers();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                _StepperHeader(step: state.topUpStep),
                const SizedBox(height: 16),
                if (state.topUpStep == TopUpStep.idle ||
                    state.topUpStep == TopUpStep.selectAmount)
                  _AmountForm(
                    controller: _amountController,
                    minAmount: _kMinAmount,
                    presetAmounts: _kPresetAmounts,
                    onSubmit: _handleTopUp,
                    isLoading: state.isLoading,
                  )
                else if (state.topUpStep == TopUpStep.paying ||
                    (state.topUpStep == TopUpStep.cancelled &&
                        state.pendingPayment == null))
                  _PayingView(
                    pending:
                        state.pendingPayment ??
                        SepayInitResponse(
                          paymentId: '',
                          paymentUrl: '',
                          amount: 0,
                          sepayCode: '',
                          expiresAt: _kEpoch,
                        ),
                    countdownSeconds: state.countdownSeconds,
                    isCancelling: state.isCancelling,
                    statusInt: _statusInt(state.paymentStatus),
                    isCancelledStep: state.topUpStep == TopUpStep.cancelled,
                    onCancel: _confirmCancel,
                    onCopyCode: () => state.pendingPayment == null
                        ? _showSnackBar('Không có mã để sao chép')
                        : _copySepayCode(state.pendingPayment!.sepayCode),
                    onCopyAccount: _copyAccount,
                    onCreateNew: () =>
                        context.read<WalletCubit>().createNewTopUp(),
                    formatCountdown: _formatCountdown,
                    bankName: _kBankName,
                    bankAccount: _kBankAccount,
                    bankOwner: _kBankOwner,
                    realtimeConnected: state.realtimeConnected,
                    paymentExpired: state.paymentExpired,
                  )
                else if (state.topUpStep == TopUpStep.cancelled)
                  // Defensive fallback — should not normally happen because
                  // `cancelTopUp` and the terminal-status handler both
                  // preserve `pendingPayment`. If it does (e.g. an external
                  // race), show a minimal "Đã huỷ" card so the wizard
                  // doesn't crash.
                  const _CancelledOnlyView()
                else if (state.topUpStep == TopUpStep.success &&
                    state.pendingPayment != null)
                  _SuccessView(
                    pending: state.pendingPayment!,
                    onCopyCode: () =>
                        _copySepayCode(state.pendingPayment!.sepayCode),
                    onCreateNew: () =>
                        context.read<WalletCubit>().createNewTopUp(),
                    onClose: () => Navigator.pop(context),
                    bankName: _kBankName,
                    bankAccount: _kBankAccount,
                    bankOwner: _kBankOwner,
                    formatTimestamp: _formatTimestamp,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _statusInt(PaymentStatus s) => s.index;
}

class _StepperHeader extends StatelessWidget {
  final TopUpStep step;
  const _StepperHeader({required this.step});

  @override
  Widget build(BuildContext context) {
    final title = step == TopUpStep.paying || step == TopUpStep.cancelled
        ? 'Quét QR để thanh toán'
        : step == TopUpStep.success
        ? 'Nạp tiền thành công'
        : 'Chọn số tiền nạp';
    final subtitle = step == TopUpStep.paying || step == TopUpStep.cancelled
        ? 'Hoàn tất giao dịch bằng ứng dụng ngân hàng'
        : step == TopUpStep.success
        ? 'Giao dịch đã được xác nhận'
        : 'Chọn mệnh giá hoặc nhập số tiền';
    final iconBg = step == TopUpStep.success
        ? const Color(0x1A10B981)
        : const Color(0xFFFEF3C7);
    final iconColor = step == TopUpStep.success
        ? const Color(0xFF10B981)
        : const Color(0xFFFB923C);

    IconData stepIcon = Icons.credit_card;
    if (step == TopUpStep.paying || step == TopUpStep.cancelled) {
      stepIcon = Icons.qr_code_2;
    } else if (step == TopUpStep.success) {
      stepIcon = Icons.check_circle;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(stepIcon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _StepDots(step: step),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final TopUpStep step;
  const _StepDots({required this.step});

  @override
  Widget build(BuildContext context) {
    final activeColor = step == TopUpStep.success
        ? const Color(0xFF10B981)
        : const Color(0xFFFB923C);
    final reached = step != TopUpStep.idle && step != TopUpStep.selectAmount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(active: true, color: activeColor),
        const SizedBox(width: 4),
        Container(
          width: 16,
          height: 1,
          color: activeColor.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 4),
        reached
            ? Icon(Icons.check, size: 10, color: activeColor)
            : Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
              ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  final Color color;
  const _Dot({required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xFFCBD5E1),
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _AmountForm extends StatelessWidget {
  final TextEditingController controller;
  final int minAmount;
  final List<int> presetAmounts;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _AmountForm({
    required this.controller,
    required this.minAmount,
    required this.presetAmounts,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Số tiền sẽ nạp',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, __) {
              final digits = normalizeVndInput(value.text);
              final amount = int.tryParse(digits) ?? 0;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    amount == 0 ? '0' : formatVndDigits(amount),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      '₫',
                      style: TextStyle(
                        color: Color(0xFFFB923C),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          const Text(
            'Mức tiền phổ biến',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, __) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presetAmounts
                    .map(
                      (amt) => _PresetChip(
                        amount: amt,
                        isSelected: value.text == amt.toString(),
                        onTap: () => controller.text = amt.toString(),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 22),
          const Text(
            'Hoặc nhập số tiền',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nhập số tiền',
                      hintStyle: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (v) {
                      final norm = normalizeVndInput(v);
                      if (norm != v) controller.text = norm;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '₫',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, __) {
              final amount = int.tryParse(value.text) ?? 0;
              if (value.text.isEmpty || amount >= minAmount) {
                return const SizedBox(height: 0);
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFEF4444),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Số tiền tối thiểu là 10.000 ₫',
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, __) {
              final amount = int.tryParse(value.text) ?? 0;
              final disabled = isLoading || amount < minAmount;
              return SizedBox(
                width: double.infinity,
                child: Material(
                  color: disabled
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: disabled ? null : onSubmit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Đang tạo mã thanh toán...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.credit_card,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  amount >= minAmount
                                      ? 'Thanh toán ${formatVnd(amount)}'
                                      : 'Tiếp tục thanh toán',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.lock,
                    color: Color(0xFFFB923C),
                    size: 11,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'QR VietQR sẽ được tạo ở bước tiếp theo. Bạn có thể quét bằng hầu hết ứng dụng ngân hàng Việt Nam.',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0x1AF97316) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFF97316)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97316),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check, color: Colors.white, size: 9),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                formatVnd(amount),
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFB923C)
                      : const Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayingView extends StatelessWidget {
  final SepayInitResponse pending;
  final int countdownSeconds;
  final bool isCancelling;
  final int statusInt;
  final bool isCancelledStep;
  final VoidCallback onCancel;
  final VoidCallback onCopyCode;
  final VoidCallback onCopyAccount;
  final VoidCallback onCreateNew;
  final String Function(int) formatCountdown;
  final String bankName;
  final String bankAccount;
  final String bankOwner;
  final bool realtimeConnected;
  final bool paymentExpired;

  const _PayingView({
    required this.pending,
    required this.countdownSeconds,
    required this.isCancelling,
    required this.statusInt,
    required this.isCancelledStep,
    required this.onCancel,
    required this.onCopyCode,
    required this.onCopyAccount,
    required this.onCreateNew,
    required this.formatCountdown,
    required this.bankName,
    required this.bankAccount,
    required this.bankOwner,
    required this.realtimeConnected,
    required this.paymentExpired,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = statusInt == 1;
    final isFailed = statusInt == 2;
    final expired = paymentExpired && !isCompleted && !isFailed;
    final effectiveStatus = isCancelledStep
        ? 3
        : expired
        ? 4
        : statusInt;

    return Column(
      children: [
        // LEFT COLUMN — amount hero + instructions + receiver info
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Số tiền cần thanh toán',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '₫',
                    style: TextStyle(
                      color: Color(0xFFFB923C),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatVndDigits(pending.amount),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hướng dẫn thanh toán',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Step(
                      number: '1',
                      text:
                          'Mở ứng dụng ngân hàng hoặc ví điện tử hỗ trợ VietQR.',
                    ),
                    _Step(
                      number: '2',
                      text:
                          'Quét mã QR hoặc nhập chính xác nội dung chuyển khoản.',
                    ),
                    _Step(
                      number: '3',
                      text:
                          'Hoàn tất thanh toán, hệ thống sẽ tự động xác nhận giao dịch.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'Nội dung chuyển khoản',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: realtimeConnected
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: realtimeConnected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          realtimeConnected ? 'Live' : 'Polling',
                          style: TextStyle(
                            color: realtimeConnected
                                ? const Color(0xFF059669)
                                : const Color(0xFFB45309),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Material(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onCopyCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x33F97316)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            pending.sepayCode,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.content_copy,
                                size: 13,
                                color: Color(0xFF475569),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Sao chép',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Vui lòng giữ nguyên nội dung chuyển khoản để giao dịch được xác nhận tự động.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              _ReceiverCard(
                bankName: bankName,
                bankAccount: bankAccount,
                bankOwner: bankOwner,
                amount: pending.amount,
                onCopyAccount: onCopyAccount,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // RIGHT COLUMN — QR card with status badge / countdown / cancel CTA
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.qr_code_2,
                        color: Color(0xFFFB923C),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quét mã VietQR',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Dùng app ngân hàng của bạn',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PaymentStatusBadge(status: effectiveStatus),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        pending.paymentUrl,
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            width: 220,
                            height: 220,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFB923C),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _CountdownRow(
                  seconds: countdownSeconds,
                  expired: expired,
                  isCompleted: isCompleted,
                  isCancelled: isCancelledStep,
                  formatCountdown: formatCountdown,
                  onCreateNew: onCreateNew,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: _StatusBanner(
                  isCompleted: isCompleted,
                  isFailed: isFailed || expired,
                  isCancelled: isCancelledStep,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _CancelButton(
                  isCancelling: isCancelling,
                  isCancelled: isCancelledStep,
                  isCompleted: isCompleted,
                  isFailed: isFailed,
                  expired: expired,
                  onPressed: onCancel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiverCard extends StatelessWidget {
  final String bankName;
  final String bankAccount;
  final String bankOwner;
  final int amount;
  final VoidCallback onCopyAccount;

  const _ReceiverCard({
    required this.bankName,
    required this.bankAccount,
    required this.bankOwner,
    required this.amount,
    required this.onCopyAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: const Text(
              'Thông tin người nhận',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
          ),
          _InfoRow(
            label: 'Ngân hàng',
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance,
                  color: Color(0xFFFB923C),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  bankName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _InfoRow(
            label: 'Số tài khoản',
            child: Row(
              children: [
                Text(
                  bankAccount,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onCopyAccount,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.content_copy,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _InfoRow(
            label: 'Chủ tài khoản',
            child: Text(
              bankOwner,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          _InfoRow(
            label: 'Số tiền',
            child: Text(
              formatVnd(amount),
              style: const TextStyle(
                color: Color(0xFFFB923C),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            last: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool last;
  const _InfoRow({required this.label, required this.child, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _CountdownRow extends StatelessWidget {
  final int seconds;
  final bool expired;
  final bool isCompleted;
  final bool isCancelled;
  final String Function(int) formatCountdown;
  final VoidCallback onCreateNew;

  const _CountdownRow({
    required this.seconds,
    required this.expired,
    required this.isCompleted,
    required this.isCancelled,
    required this.formatCountdown,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    final showTimer = !expired && !isCompleted && !isCancelled && seconds > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isCompleted
                  ? 'Mã đã hoàn tất'
                  : isCancelled
                  ? 'Giao dịch đã được huỷ'
                  : 'Mã QR hết hạn sau',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          if (showTimer)
            Text(
              formatCountdown(seconds),
              style: TextStyle(
                color: seconds < 120
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                height: 1.0,
              ),
            )
          else if (expired)
            Material(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onCreateNew,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Tạo Giao Dịch Mới',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool isCompleted;
  final bool isFailed;
  final bool isCancelled;

  const _StatusBanner({
    required this.isCompleted,
    required this.isFailed,
    required this.isCancelled,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _Banner(
        bg: const Color(0x0A10B981),
        border: const Color(0x3310B981),
        icon: const Icon(Icons.check, color: Colors.white, size: 14),
        iconBg: const Color(0xFF10B981),
        titleColor: const Color(0xFF059669),
        title: 'Thanh toán thành công',
        subtitle: 'Giao dịch đã được xác nhận tự động.',
      );
    }
    if (isCancelled) {
      return _Banner(
        bg: const Color(0x0F64748B),
        border: const Color(0x3364748B),
        icon: const Icon(Icons.block, color: Colors.white, size: 14),
        iconBg: const Color(0xFF64748B),
        titleColor: const Color(0xFF475569),
        title: 'Giao dịch đã được huỷ',
        subtitle:
            'Nếu bạn đã chuyển khoản, vui lòng liên hệ hỗ trợ để được hoàn tiền.',
      );
    }
    if (isFailed) {
      return _Banner(
        bg: const Color(0x0FEF4444),
        border: const Color(0x33EF4444),
        icon: const Icon(Icons.close, color: Colors.white, size: 14),
        iconBg: const Color(0xFFEF4444),
        titleColor: const Color(0xFFDC2626),
        title: 'Không thể xác nhận thanh toán',
        subtitle:
            'Giao dịch chưa được hoàn tất. Vui lòng kiểm tra lại hoặc thử lại.',
      );
    }
    return _Banner(
      bg: Colors.white,
      border: const Color(0xFFE2E8F0),
      icon: const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          color: Color(0xFFF59E0B),
          strokeWidth: 2,
        ),
      ),
      iconBg: const Color(0xFFFEF3C7),
      titleColor: const Color(0xFF0F172A),
      title: 'Đang chờ thanh toán',
      subtitle: 'Hệ thống sẽ tự động xác nhận sau khi nhận được giao dịch.',
    );
  }
}

class _Banner extends StatelessWidget {
  final Color bg;
  final Color border;
  final Widget icon;
  final Color iconBg;
  final Color titleColor;
  final String title;
  final String subtitle;

  const _Banner({
    required this.bg,
    required this.border,
    required this.icon,
    required this.iconBg,
    required this.titleColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final bool isCancelling;
  final bool isCancelled;
  final bool isCompleted;
  final bool isFailed;
  final bool expired;
  final VoidCallback onPressed;

  const _CancelButton({
    required this.isCancelling,
    required this.isCancelled,
    required this.isCompleted,
    required this.isFailed,
    required this.expired,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled =
        isCancelling || isCancelled || isCompleted || isFailed || expired;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: disabled ? null : onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x33EF4444)),
                ),
                child: isCancelling
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: Color(0xFFEF4444),
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Đang huỷ...',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Huỷ thanh toán',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sau khi huỷ, nếu bạn đã chuyển khoản vui lòng liên hệ hỗ trợ để được hoàn tiền.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, height: 1.4),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final SepayInitResponse pending;
  final VoidCallback onCopyCode;
  final VoidCallback onCreateNew;
  final VoidCallback onClose;
  final String bankName;
  final String bankAccount;
  final String bankOwner;
  final String Function(DateTime?) formatTimestamp;

  const _SuccessView({
    required this.pending,
    required this.onCopyCode,
    required this.onCreateNew,
    required this.onClose,
    required this.bankName,
    required this.bankAccount,
    required this.bankOwner,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0x1A10B981),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nạp tiền thành công',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Giao dịch đã được xác nhận và cộng vào ví của bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Text(
                  'Số tiền đã nạp',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '+',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      formatVndDigits(pending.amount),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '₫',
                      style: TextStyle(
                        color: Color(0xFFFB923C),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9)),
                    ),
                  ),
                  child: const Text(
                    'Chi tiết giao dịch',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
                _DetailRow(
                  label: 'Mã giao dịch',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pending.sepayCode,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: onCopyCode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.content_copy,
                                  size: 11,
                                  color: Color(0xFF475569),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Sao chép',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _DetailRow(
                  label: 'Phương thức',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code_2,
                        color: Color(0xFFFB923C),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'VietQR · $bankName',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _DetailRow(
                  label: 'Người nhận',
                  child: Text(
                    bankOwner,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                _DetailRow(
                  label: 'Trạng thái',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1A10B981),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x3310B981)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 5,
                          height: 5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Hoàn thành',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onCreateNew,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Nạp thêm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'Đóng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool last;
  const _DetailRow({
    required this.label,
    required this.child,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(alignment: Alignment.centerRight, child: child),
          ),
        ],
      ),
    );
  }
}

/// Defensive fallback shown when the wizard is in the `cancelled` step
/// but `pendingPayment` is somehow `null` (so the `_PayingView` cannot
/// render the QR / sepay code). Mirrors the minimal "Da huy - Tao ma
/// moi" pattern used on web for the same edge case.
class _CancelledOnlyView extends StatelessWidget {
  const _CancelledOnlyView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0x0F64748B),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.block, color: Color(0xFF64748B), size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Giao dịch đã được huỷ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn đã huỷ giao dịch nạp tiền này. Bấm "Tạo giao dịch mới" để bắt đầu lại.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.read<WalletCubit>().createNewTopUp(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Tạo Giao Dịch Mới',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
