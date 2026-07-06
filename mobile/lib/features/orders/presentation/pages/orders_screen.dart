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
      backgroundColor: const Color(0xFFF9FAFB), // Modern, clean background
      appBar: const _AppBar(),
      body: FutureBuilder<List<OrderHistoryItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF97316)),
            );
          }

          if (snapshot.hasError) {
            return const _ErrorState();
          }

          final orders = snapshot.data ?? const <OrderHistoryItem>[];

          if (orders.isEmpty) {
            return const _EmptyState();
          }

          // Group orders by date for a more structured timeline
          final groupedOrders = _groupOrdersByDate(orders);

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _SearchBar(),
                ),
              ),
              SliverToBoxAdapter(
                child: _FilterBar(
                  selectedFilter: _selectedFilter,
                  onSelected: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final date = groupedOrders.keys.elementAt(index);
                  final dailyOrders = groupedOrders[date]!;
                  return _TimelineSection(
                    date: date,
                    orders: dailyOrders,
                    formatTime: _formatTime,
                  );
                }, childCount: groupedOrders.length),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<OrderHistoryItem>> _groupOrdersByDate(
    List<OrderHistoryItem> orders,
  ) {
    final Map<DateTime, List<OrderHistoryItem>> grouped = {};
    for (final order in orders) {
      final date = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(order);
    }
    return grouped;
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
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
          onPressed: () {
            // TODO: Implement filter functionality
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm theo ID tủ, trạng thái...',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFFF97316),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const _FilterBar({required this.selectedFilter, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const chips = ['Hôm nay', 'Tuần này', 'Tháng này', 'Tất cả'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: chips
            .map(
              (chip) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: selectedFilter == chip,
                  label: Text(chip),
                  onSelected: (_) => onSelected(chip),
                  labelStyle: TextStyle(
                    color: selectedFilter == chip
                        ? Colors.white
                        : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: const Color(0xFFF97316),
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                    side: BorderSide(
                      color: selectedFilter == chip
                          ? Colors.transparent
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final DateTime date;
  final List<OrderHistoryItem> orders;
  final String Function(DateTime) formatTime;

  const _TimelineSection({
    required this.date,
    required this.orders,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateHeader(date: date),
          const SizedBox(height: 16),
          ...orders.map(
            (order) => _TimelineTile(
              order: order,
              isLast: orders.indexOf(order) == orders.length - 1,
              formatTime: formatTime,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final OrderHistoryItem order;
  final bool isLast;
  final String Function(DateTime) formatTime;

  const _TimelineTile({
    required this.order,
    required this.isLast,
    required this.formatTime,
  });

  IconData _getIcon() {
    switch (order.status.toLowerCase()) {
      case 'completed':
        return Icons.lock_open_rounded;
      case 'initiated':
      case 'paid':
      case 'active':
      case 'reserved':
        return Icons.lock_rounded;
      case 'cancelled':
        return Icons.history_rounded;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Color _getIconColor() {
    switch (order.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF22C55E);
      case 'initiated':
      case 'paid':
      case 'active':
      case 'reserved':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineIndicator(
          icon: _getIcon(),
          color: _getIconColor(),
          isLast: isLast,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: _OrderCard(
              order: order,
              formatTime: formatTime,
              iconColor: _getIconColor(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isLast;

  const _TimelineIndicator({
    required this.icon,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(child: Icon(icon, size: 20, color: color)),
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 100, // Provides consistent spacing
            color: const Color(0xFFE2E8F0),
          ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderHistoryItem order;
  final String Function(DateTime) formatTime;
  final Color iconColor;

  const _OrderCard({
    required this.order,
    required this.formatTime,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF475569).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${order.statusLabel}: ${order.title}',
                  maxLines: 2, // Allow wrapping for very long status labels
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formatTime(order.createdAt),
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.location.isEmpty
                ? 'Không có thông tin vị trí'
                : order.location,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Không tải được lịch sử đơn hàng',
        style: TextStyle(color: Color(0xFF475569)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext antext) {
    return const Center(child: Text('Chưa có đơn hàng nào'));
  }
}
