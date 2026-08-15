import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sepay_init_response.dart';
import '../controllers/wallet_cubit.dart';
import '../controllers/wallet_state.dart';
import '../../../payment_failed/domain/entities/payment_failed_info.dart';
import '../../../payment_success/domain/entities/payment_success_info.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedPaymentMethod = 'sepay';

  Timer? _countdownTimer;
  Timer? _pollingTimer;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'sepay',
      'name': 'SePay',
      'subtitle': 'Miễn phí thanh toán',
      'icon': Icons.account_balance,
      'color': const Color(0xFF00B14F),
    },
  ];

  void _handleTopUp() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      _showSnackBar('Vui lòng nhập số tiền hợp lệ');
      return;
    }

    if (_selectedPaymentMethod != 'sepay') {
      _showSnackBar('Phương thức $_selectedPaymentMethod chưa được hỗ trợ');
      return;
    }

    final cubit = context.read<WalletCubit>();
    final sepayResponse = await cubit.topUp(amount);

    if (!mounted) return;

    if (sepayResponse == null) {
      final errorMessage =
          cubit.state.errorMessage ?? 'Khởi tạo thanh toán thất bại';
      _showSnackBar(errorMessage);
      Navigator.pushNamed(
        context,
        '/payment-failed',
        arguments: PaymentFailedRequest(
          amount: amount.toInt(),
          paymentMethod: _selectedPaymentMethod,
          reason: errorMessage,
        ),
      );
    }
  }

  void _startPayingTimers(WalletCubit cubit) {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        cubit.tickCountdown();
      },
    );

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!mounted) return;
        cubit.pollPaymentStatus();
      },
    );
  }

  void _stopTimers() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    _countdownTimer = null;
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopTimers();
    _amountController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 236, 129, 53),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nạp tiền vào ví',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<WalletCubit, WalletState>(
        listenWhen: (prev, next) =>
            prev.topUpStep != next.topUpStep ||
            prev.errorMessage != next.errorMessage,
        listener: (context, state) {
          final cubit = context.read<WalletCubit>();
          if (state.topUpStep == TopUpStep.paying) {
            _startPayingTimers(cubit);
          } else if (state.topUpStep == TopUpStep.success) {
            _stopTimers();
            Navigator.pushNamed(
              context,
              '/payment-success',
              arguments: PaymentSuccessRequest(
                paidAmount: state.pendingPayment?.amount ?? 0,
                orderCode: state.pendingPayment?.sepayCode ?? '',
              ),
            );
          } else {
            _stopTimers();
          }
        },
        builder: (context, state) {
          if (state.topUpStep == TopUpStep.paying &&
              state.pendingPayment != null) {
            return _PayingView(
              pending: state.pendingPayment!,
              countdownSeconds: state.countdownSeconds,
              isCancelling: state.isCancelling,
              onCancel: () => _confirmCancel(context),
              onCopyCode: () =>
                  _copySepayCode(context, state.pendingPayment!.sepayCode),
            );
          }
          return _buildAmountForm(state);
        },
      ),
    );
  }

  Widget _buildAmountForm(WalletState state) {
    final balance = state.overview?.balance ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'SỐ DƯ VÍ:',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatMoney(balance)}đ',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 232, 154, 52),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số tiền cần nạp',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        suffixText: 'đ',
                        suffixStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _AmountChip(
                          amount: 200000,
                          isSelected: _amountController.text == '200000',
                          onTap: () => setState(
                            () => _amountController.text = '200000',
                          ),
                        ),
                        _AmountChip(
                          amount: 500000,
                          isSelected: _amountController.text == '500000',
                          onTap: () => setState(
                            () => _amountController.text = '500000',
                          ),
                        ),
                        _AmountChip(
                          amount: 1000000,
                          isSelected: _amountController.text == '1000000',
                          onTap: () => setState(
                            () => _amountController.text = '1000000',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'NGUỒN TIỀN',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ..._paymentMethods.map(
            (method) => _PaymentMethodTile(
              method: method,
              isSelected: _selectedPaymentMethod == method['id'],
              onSelected: () =>
                  setState(() => _selectedPaymentMethod = method['id']),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _handleTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 235, 130, 65),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Nạp tiền',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final cubit = context.read<WalletCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Huỷ giao dịch nạp tiền?'),
        content: const Text(
          'Bạn có chắc muốn huỷ giao dịch đang chờ? Tiền chưa chuyển sẽ không bị trừ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Huỷ giao dịch'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await cubit.cancelTopUp();
  }

  Future<void> _copySepayCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    _showSnackBar('Đã sao chép mã $code');
  }

  String _formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class _PayingView extends StatelessWidget {
  final SepayInitResponse pending;
  final int countdownSeconds;
  final bool isCancelling;
  final VoidCallback onCancel;
  final VoidCallback onCopyCode;

  const _PayingView({
    required this.pending,
    required this.countdownSeconds,
    required this.isCancelling,
    required this.onCancel,
    required this.onCopyCode,
  });

  String _formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (countdownSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (countdownSeconds % 60).toString().padLeft(2, '0');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7CF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Color(0xFFD82D2D),
                ),
                const SizedBox(width: 6),
                Text(
                  'Còn lại: $minutes:$seconds',
                  style: const TextStyle(
                    color: Color(0xFFD82D2D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Quét QR để thanh toán ${_formatMoney(pending.amount)}đ',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    pending.paymentUrl,
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 240,
                      height: 240,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 64,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 240,
                        height: 240,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFD8D64),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onCopyCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Mã: ${pending.sepayCode}',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hướng dẫn:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '1. Mở app ngân hàng hoặc VietQR\n'
                  '2. Quét mã QR ở trên\n'
                  '3. Xác nhận chuyển đúng số tiền & nội dung',
                  style: TextStyle(color: Color(0xFF1E40AF), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isCancelling ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
              child: isCancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Huỷ giao dịch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountChip({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color.fromARGB(255, 247, 167, 76) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD82D8B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          '$_formatMoney(amount)đ',
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  String _formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final Map<String, dynamic> method;
  final bool isSelected;
  final VoidCallback onSelected;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 246, 146, 46)
                : const Color(0xFFF1F5F9),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (method['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(method['icon'], color: method['color'], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    method['subtitle'],
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.radio_button_checked,
                color: Color.fromARGB(255, 239, 152, 54),
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: Color(0xFFCBD5E1),
              ),
          ],
        ),
      ),
    );
  }
}
