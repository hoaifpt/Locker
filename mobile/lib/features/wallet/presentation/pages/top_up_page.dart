import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
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

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'sepay',
      'name': 'SePay',
      'subtitle': 'Miễn phí thanh toán',
      'icon': Icons.account_balance,
      'color': const Color(0xFF00B14F),
    },
    // Future services can be added here
    // {
    //   'id': 'momo',
    //   'name': 'MoMo',
    //   'subtitle': 'Phí 1.1% GD',
    //   'icon': Icons.payment,
    //   'color': const Color(0xFFD82D8B),
    // },
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
    final url = await cubit.topUp(
      amount,
    ); // Note: Should check if WalletCubit.topUp needs updating to call initSePayTopUp

    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          Navigator.pushNamed(
            context,
            '/payment-success',
            arguments: PaymentSuccessRequest(
              paidAmount: amount.toInt(),
              orderCode: 'TOPUP-${DateTime.now().millisecondsSinceEpoch}',
            ),
          );
        }
      } else {
        if (mounted) {
          _showSnackBar('Không thể mở trang thanh toán SePay');
          Navigator.pushNamed(
            context,
            '/payment-failed',
            arguments: PaymentFailedRequest(
              amount: amount.toInt(),
              paymentMethod: _selectedPaymentMethod,
              reason: 'Không thể mở URL thanh toán',
            ),
          );
        }
      }
    } else {
      final currentState = context.read<WalletCubit>().state;
      final errorMessage =
          currentState.errorMessage ?? 'Khởi tạo thanh toán thất bại';

      if (mounted) {
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
        backgroundColor: const Color.fromARGB(
          255,
          236,
          129,
          53,
        ), // MoMo-like pink/red
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
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          final balance = state.overview?.balance ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                      // Amount Input
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
                          // Quick Select Chips
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
                // Payment Methods List
                ..._paymentMethods.map(
                  (method) => _PaymentMethodTile(
                    method: method,
                    isSelected: _selectedPaymentMethod == method['id'],
                    onSelected: () =>
                        setState(() => _selectedPaymentMethod = method['id']),
                  ),
                ),
                const SizedBox(height: 40),
                // Bottom Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleTopUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 130, 65),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
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
        },
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
          color: isSelected
              ? const Color.fromARGB(255, 247, 167, 76)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD82D8B)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          '${_formatMoney(amount)}đ',
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
                color: (method['color'] as Color).withOpacity(0.1),
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
