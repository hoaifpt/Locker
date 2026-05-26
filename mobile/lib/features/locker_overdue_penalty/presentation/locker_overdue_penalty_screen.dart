import 'package:flutter/material.dart';
import '../domain/entities/locker_overdue_info.dart';

class LockerOverduePenaltyScreen extends StatelessWidget {
  final LockerOverdueInfo info;

  const LockerOverduePenaltyScreen({super.key, required this.info});

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final total = info.totalPenalty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tủ quá hạn'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAlertCard(context),
                const SizedBox(height: 24),
                _buildDetailsCard(context, total),
                const SizedBox(height: 24),
                _buildActions(context, total),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7CD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0x19F27B50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFF27B50)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đã quá thời gian lưu trữ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Kiện hàng của bạn tại ',
                  style: TextStyle(color: Color(0xFF475569), fontSize: 14),
                ),
                TextSpan(
                  text: info.lockerId,
                  style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const TextSpan(
                  text: ' đã vượt quá thời gian 48 giờ lấy hàng miễn phí.',
                  style: TextStyle(color: Color(0xFF475569), fontSize: 14),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('CHI TIẾT PHÍ PHẠT',
              style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thời gian quá hạn',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
              Text('${info.overdue.inDays} Ngày',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phí phạt mỗi ngày',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
              Text(_formatCurrency(info.dailyFee),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng phí phạt cần thanh toán',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text(_formatCurrency(total),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF27B50))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF27B50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            // TODO: integrate payment
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Thanh toán $total')));
          },
          child: Text('Thanh toán ${_formatCurrency(total)} qua Ví điện tử',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {},
          child: const Text('Liên hệ hỗ trợ',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        ),
      ],
    );
  }
}
