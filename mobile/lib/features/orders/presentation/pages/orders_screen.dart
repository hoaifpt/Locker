import 'package:flutter/material.dart';

import '../../domain/entities/order_history_item.dart';
import '../../domain/usecases/get_orders_usecase.dart';

class OrdersScreen extends StatefulWidget {
  final GetOrdersUsecase getOrders;

  const OrdersScreen({
    super.key,
    required this.getOrders,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final Future<List<OrderHistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.getOrders();
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dateTime.day.toString().padLeft(2, '0')} ${months[dateTime.month - 1]} ${dateTime.year} • ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Lịch sử truy cập',
          style: TextStyle(
            color: Color(0xFF4A4036),
            fontSize: 20,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: FutureBuilder<List<OrderHistoryItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFB923C)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Không tải được lịch sử đơn hàng',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            );
          }

          final orders = snapshot.data ?? const <OrderHistoryItem>[];

          if (orders.isEmpty) {
            return const Center(
              child: Text('Chưa có đơn hàng nào'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: orders.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _FilterChips(
                  onSelected: (_) {},
                );
              }

              final order = orders[index - 1];
              return _OrderCard(
                order: order,
                formatDate: _formatDate,
              );
            },
          );
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _FilterChips({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const chips = [
      ('Hôm nay', true),
      ('Hôm qua', false),
      ('Tuần này', false),
      ('Date', false),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .map(
              (chip) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  selected: chip.$2,
                  label: Text(chip.$1),
                  onSelected: (_) => onSelected(chip.$1),
                  labelStyle: TextStyle(
                    color: chip.$2 ? Colors.white : const Color(0xFF8C8075),
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: const Color(0xFFFF8C42),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderHistoryItem order;
  final String Function(DateTime) formatDate;

  const _OrderCard({
    required this.order,
    required this.formatDate,
  });

  Color _statusColor() {
    switch (order.status) {
      case 'completed':
        return const Color(0xFF16A34A);
      case 'pending':
        return const Color(0xFFE58A00);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF8C8075);
    }
  }

  Color _statusBackground() {
    switch (order.status) {
      case 'completed':
        return const Color(0xFFEFFAF3);
      case 'pending':
        return const Color(0x0CFF8C42);
      case 'cancelled':
        return const Color(0x0CEB4A4A);
      default:
        return const Color(0xFFF9FAFB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Color(0xFFFB923C), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      style: const TextStyle(
                        color: Color(0xFF4A4036),
                        fontSize: 15,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.location,
                      style: const TextStyle(
                        color: Color(0xFF8C8075),
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBackground(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    color: _statusColor(),
                    fontSize: 11,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.lockerCode,
                style: const TextStyle(
                  color: Color(0xFF4A4036),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatDate(order.createdAt),
                style: const TextStyle(
                  color: Color(0xFF8C8075),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền',
                style: TextStyle(
                  color: Color(0xFF8C8075),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${order.amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                style: const TextStyle(
                  color: Color(0xFF4A4036),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
