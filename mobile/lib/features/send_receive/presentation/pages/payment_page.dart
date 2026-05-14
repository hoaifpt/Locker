import 'package:flutter/material.dart';

import '../../../payment_success/domain/entities/payment_success_info.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const PaymentPage({
    super.key,
    required this.orderData,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'ebox-wallet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 32,
          children: [
            _buildOrderInfo(),
            _buildCostBreakdown(),
            _buildPaymentMethods(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 52,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Thanh toán gửi đồ',
        style: TextStyle(
          color: Color(0xFF111827),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        const Text(
          'Thông tin gửi đồ',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            spacing: 16,
            children: [
              // Locker Image
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: Image.asset(
                  'assets/Medium size locker compartment.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Locker Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    const Text(
                      'Locker A-102',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Khu vực sảnh A',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        _buildTag('Size: Vừa'),
                        _buildTag('4 Giờ'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x19F27B50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x33F27B50)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFF27B50),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCostBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        const Text(
          'Chi tiết chi phí',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            spacing: 12,
            children: [
              _buildCostRow('Phí lưu trữ', '15.000đ'),
              _buildCostRow('Phí dịch vụ', '2.000đ'),
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                ),
                child: _buildCostRow(
                  'Tổng thanh toán',
                  '17.000đ',
                  isTotal: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color:
                  isTotal ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color:
                  isTotal ? const Color(0xFFF27B50) : const Color(0xFF0F172A),
              fontSize: isTotal ? 20 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        const Text(
          'Phương thức thanh toán',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        _buildPaymentMethodCard(
          icon: Icons.account_balance_wallet,
          title: 'Ví E-BOX',
          subtitle: 'Số dư: 500.000đ',
          value: 'ebox-wallet',
          isSelected: selectedPaymentMethod == 'ebox-wallet',
          onTap: () => setState(() => selectedPaymentMethod = 'ebox-wallet'),
          backgroundColor: const Color(0xFFF27B50),
          iconColor: Colors.white,
        ),
        _buildPaymentMethodCard(
          icon: Icons.account_balance_wallet,
          title: 'Ví Momo',
          subtitle: 'Thanh toán nhanh',
          value: 'momo',
          isSelected: selectedPaymentMethod == 'momo',
          onTap: () => setState(() => selectedPaymentMethod = 'momo'),
          backgroundColor: const Color(0xFFA50064),
          iconColor: Colors.white,
        ),
        _buildPaymentMethodCard(
          icon: Icons.credit_card,
          title: 'Thẻ ngân hàng',
          subtitle: 'Visa, Mastercard',
          value: 'bank',
          isSelected: selectedPaymentMethod == 'bank',
          onTap: () => setState(() => selectedPaymentMethod = 'bank'),
          backgroundColor: const Color(0xFFE2E8F0),
          iconColor: const Color(0xFF64748B),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x0CF27B50) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFF27B50) : const Color(0xFFF1F5F9),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF27B50)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF27B50),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () {
            final totalPrice =
                (widget.orderData['totalPrice'] as num?)?.toInt() ?? 17000;
            final lockerCode =
                widget.orderData['lockerCode'] as String? ?? 'Locker A-102';
            final transactionId =
                'TXN_${DateTime.now().millisecondsSinceEpoch}_${selectedPaymentMethod.toUpperCase()}';

            final paymentSuccessRequest = PaymentSuccessRequest(
              paidAmount: totalPrice,
              orderCode: transactionId,
              lockerHub: lockerCode,
              transactionId: transactionId,
              paymentMethod: selectedPaymentMethod,
            );

            Navigator.of(context).pushNamed(
              '/payment-success',
              arguments: paymentSuccessRequest,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9431),
            elevation: 8,
            shadowColor: const Color(0x33FF9431),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: const Text(
            'Thanh toán ngay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
