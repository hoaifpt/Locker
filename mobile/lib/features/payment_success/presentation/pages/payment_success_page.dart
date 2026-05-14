import 'package:flutter/material.dart';

import '../../data/payment_success_repository.dart';
import '../../domain/entities/payment_success_info.dart';
import '../../domain/usecases/get_payment_success_usecase.dart';

class PaymentSuccessPage extends StatefulWidget {
  final PaymentSuccessRequest? request;

  const PaymentSuccessPage({super.key, this.request});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  late final GetPaymentSuccessUsecase _getPaymentSuccess;
  late final Future<PaymentSuccessInfo> _future;

  @override
  void initState() {
    super.initState();
    _getPaymentSuccess = GetPaymentSuccessUsecase(PaymentSuccessRepository());
    _future = _getPaymentSuccess(widget.request);
  }

  String _formatPrice(int value) => '${value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )}đ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<PaymentSuccessInfo>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(
                  child: Text('Không tải được thông tin thanh toán'));
            }

            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF5F0),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x33F27B50),
                                  blurRadius: 30,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 56,
                              color: Color(0xFFF27B50),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 24,
                              fontFamily: 'Aleo',
                              fontWeight: FontWeight.w700,
                              height: 1.33,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 16,
                              fontFamily: 'Aleo',
                              fontWeight: FontWeight.w400,
                              height: 1.63,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _InfoCard(
                            amount: _formatPrice(data.paidAmount),
                            lockerHub: data.lockerHub,
                            transactionId: data.transactionId,
                            orderCode: data.orderCode,
                            paymentMethod: data.paymentMethod,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/home', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF27B50),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: const Text(
                        'Quay lại trang chủ',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Aleo',
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Xem hóa đơn điện tử',
                      style: TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 14,
                        fontFamily: 'Aleo',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String amount;
  final String lockerHub;
  final String transactionId;
  final String orderCode;
  final String paymentMethod;

  const _InfoCard({
    required this.amount,
    required this.lockerHub,
    required this.transactionId,
    required this.orderCode,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoRow(
              label: 'Số tiền đã thanh toán:', value: amount, boldValue: true),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          _InfoItem(label: 'Locker Hub', value: lockerHub),
          const SizedBox(height: 16),
          _InfoItem(label: 'Transaction ID', value: transactionId),
          const SizedBox(height: 16),
          _InfoItem(label: 'Order Code', value: orderCode),
          const SizedBox(height: 16),
          _InfoItem(label: 'Payment Method', value: paymentMethod),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool boldValue;

  const _InfoRow({
    required this.label,
    required this.value,
    this.boldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF71717A),
            fontSize: 14,
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: boldValue ? 18 : 16,
            fontFamily: 'Liberation Sans',
            fontWeight: boldValue ? FontWeight.w700 : FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$label:',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF71717A),
            fontSize: 14,
            fontFamily: 'Liberation Sans',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontFamily: 'Liberation Sans',
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
