import 'package:flutter/material.dart';

class PaymentFailedHintCard extends StatelessWidget {
  const PaymentFailedHintCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFE63946), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bạn có thể thử lại sau vài giây hoặc đổi sang ví E-BOX để thanh toán nhanh hơn.',
              style: TextStyle(
                color: Color(0xFF7F1D1D),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                height: 1.57,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
