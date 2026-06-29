import 'package:flutter/material.dart';

import '../../domain/entities/order_history_item.dart';
import '../../domain/usecases/get_orders_usecase.dart';

class OrdersScreen extends StatefulWidget {
  final GetOrdersUsecase getOrders;

  const OrdersScreen({super.key, required this.getOrders});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final Future<List<OrderHistoryItem>> _future;
  String _selectedFilter = 'Hôm nay';

  @override
  void initState() {
    super.initState();
    _future = widget.getOrders();
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDateHeader(DateTime dateTime) {
    return 'HÔM NAY - ${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
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
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<OrderHistoryItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF27B50)),
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
            return const Center(child: Text('Chưa có đơn hàng nào'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _SearchField(),
              const SizedBox(height: 16),
              _FilterChips(
                selectedFilter: _selectedFilter,
                onSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                _formatDateHeader(DateTime.now()),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              ...orders.map(
                (order) => _TimelineItem(
                  order: order,
                  isLast: orders.indexOf(order) == orders.length - 1,
                  formatTime: _formatTime,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search logs (e.g. Locker ID)...',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFFF27B50),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const _FilterChips({required this.selectedFilter, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const chips = [('Hôm nay', true), ('Hôm qua', false), ('Tuần này', false)];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .map(
              (chip) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: selectedFilter == chip.$1,
                  label: Text(chip.$1),
                  onSelected: (_) => onSelected(chip.$1),
                  labelStyle: TextStyle(
                    color: selectedFilter == chip.$1
                        ? Colors.white
                        : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: const Color(0xFFF27B50),
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

class _TimelineItem extends StatelessWidget {
  final OrderHistoryItem order;
  final bool isLast;
  final String Function(DateTime) formatTime;

  const _TimelineItem({
    required this.order,
    required this.isLast,
    required this.formatTime,
  });

  IconData _getIcon() {
    switch (order.status.toLowerCase()) {
      case 'completed':
        return Icons.lock_open_rounded;
      case 'pending':
        return Icons.lock_rounded;
      case 'cancelled':
        return Icons.history_rounded;
      default:
        return Icons.key_rounded;
    }
  }

  Color _getIconColor() {
    switch (order.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFF27B50);
      case 'pending':
        return const Color(0xFFF27B50);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline Left Column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getIconColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(_getIcon(), size: 18, color: _getIconColor()),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFE2E8F0)),
                  ),
              ],
            ),
          ),
          // Timeline Right Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${order.statusLabel} ${order.lockerCode}',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getIconColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            formatTime(order.createdAt),
                            style: TextStyle(
                              color: _getIconColor(),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.location,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
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
