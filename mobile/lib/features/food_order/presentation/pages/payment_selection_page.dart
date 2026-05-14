import 'package:flutter/material.dart';

import '../../../payment_success/domain/entities/payment_success_info.dart';

class EBoxPaymentSelection extends StatefulWidget {
  final int totalAmount;
  final int itemCount;
  final String orderCode;

  const EBoxPaymentSelection({
    super.key,
    required this.totalAmount,
    required this.itemCount,
    required this.orderCode,
  });

  @override
  State<EBoxPaymentSelection> createState() => _EBoxPaymentSelectionState();
}

class _EBoxPaymentSelectionState extends State<EBoxPaymentSelection> {
  static const int _shippingFee = 15000;
  _PaymentMethod _selectedMethod = _PaymentMethod.eBoxWallet;

  String _formatPrice(int value) => '${value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )}đ';

  int get _subtotal => widget.totalAmount - _shippingFee;

  String get _paymentMethodLabel {
    switch (_selectedMethod) {
      case _PaymentMethod.eBoxWallet:
        return 'Ví E-BOX';
      case _PaymentMethod.bankCard:
        return 'Thẻ ngân hàng';
      case _PaymentMethod.momo:
        return 'Momo';
      case _PaymentMethod.applePay:
        return 'Apple Pay';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontFamily: 'Aleo',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          children: [
            _PaymentSummaryCard(
              total: widget.totalAmount,
              itemCount: widget.itemCount,
              orderCode: widget.orderCode,
              subtotal: _subtotal,
              shippingFee: _shippingFee,
              formatPrice: _formatPrice,
            ),
            const SizedBox(height: 24),
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontFamily: 'Aleo',
                fontWeight: FontWeight.w700,
                height: 1.56,
              ),
            ),
            const SizedBox(height: 12),
            _PaymentMethodTile(
              title: 'Ví E-BOX',
              subtitle: 'Số dư: 1.200.000đ',
              icon: Icons.account_balance_wallet_rounded,
              iconBg: const Color(0xFFFFEDD5),
              selected: _selectedMethod == _PaymentMethod.eBoxWallet,
              onTap: () => setState(() {
                _selectedMethod = _PaymentMethod.eBoxWallet;
              }),
            ),
            const SizedBox(height: 12),
            _PaymentMethodTile(
              title: 'Thẻ ngân hàng',
              subtitle: 'Visa, Mastercard, JCB',
              icon: Icons.credit_card_rounded,
              iconBg: const Color(0xFFEFF6FF),
              selected: _selectedMethod == _PaymentMethod.bankCard,
              onTap: () => setState(() {
                _selectedMethod = _PaymentMethod.bankCard;
              }),
            ),
            const SizedBox(height: 12),
            _PaymentMethodTile(
              title: 'Momo',
              subtitle: 'Thanh toán qua ứng dụng Momo',
              icon: Icons.account_balance_wallet_outlined,
              iconBg: const Color(0xFFFCE7F3),
              selected: _selectedMethod == _PaymentMethod.momo,
              onTap: () => setState(() {
                _selectedMethod = _PaymentMethod.momo;
              }),
            ),
            const SizedBox(height: 12),
            _PaymentMethodTile(
              title: 'Apple Pay',
              subtitle: 'Thanh toán một chạm bảo mật',
              icon: Icons.phone_iphone_rounded,
              iconBg: const Color(0xFFE5E7EB),
              selected: _selectedMethod == _PaymentMethod.applePay,
              onTap: () => setState(() {
                _selectedMethod = _PaymentMethod.applePay;
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/payment-success',
                  arguments: PaymentSuccessRequest(
                    paidAmount: widget.totalAmount,
                    orderCode: widget.orderCode,
                    transactionId: 'TXN-${widget.orderCode}',
                    paymentMethod: _paymentMethodLabel,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF27B50),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Xác nhận thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _PaymentMethod { eBoxWallet, bankCard, momo, applePay }

class _PaymentSummaryCard extends StatelessWidget {
  final int total;
  final int itemCount;
  final String orderCode;
  final int subtotal;
  final int shippingFee;
  final String Function(int) formatPrice;

  const _PaymentSummaryCard({
    required this.total,
    required this.itemCount,
    required this.orderCode,
    required this.subtotal,
    required this.shippingFee,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG THANH TOÁN',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontFamily: 'Alexandria',
              fontWeight: FontWeight.w400,
              height: 1.43,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPrice(total),
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 30,
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              Text(
                '$itemCount sản phẩm',
                style: const TextStyle(
                  color: Color(0xFFF27B50),
                  fontSize: 14,
                  fontFamily: 'Aleo',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 12),
          Text(
            'Mã đơn hàng: $orderCode',
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 14,
              fontFamily: 'Liberation Mono',
              fontWeight: FontWeight.w500,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryLine(label: 'Tạm tính', value: formatPrice(subtotal)),
          const SizedBox(height: 8),
          _SummaryLine(label: 'Phí giao hàng', value: formatPrice(shippingFee)),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 14,
            fontFamily: 'Aleo',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF8F6) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFFF27B50) : const Color(0x00000000),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF111827), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontFamily: 'Aleo',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color:
                  selected ? const Color(0xFFF27B50) : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}
