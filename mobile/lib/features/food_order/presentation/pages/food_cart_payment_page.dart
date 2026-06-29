import 'package:flutter/material.dart';

import 'payment_selection_page.dart';

class FoodCartEntry {
  final String id;
  final String name;
  final String description;
  final int price;
  final int quantity;
  final String imageUrl;

  const FoodCartEntry({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}

class FoodCartPaymentArgs {
  final List<FoodCartEntry> cartItems;
  final List<FoodCartEntry> availableItems;
  final String? orderCode;

  const FoodCartPaymentArgs({
    required this.cartItems,
    required this.availableItems,
    this.orderCode,
  });
}

class EBoxFoodCartPayment extends StatefulWidget {
  final FoodCartPaymentArgs? initialData;

  const EBoxFoodCartPayment({super.key, this.initialData});

  @override
  State<EBoxFoodCartPayment> createState() => _EBoxFoodCartPaymentState();
}

class _EBoxFoodCartPaymentState extends State<EBoxFoodCartPayment> {
  static const int _shippingFee = 15000;

  late final List<_CartItem> _items;
  late final List<_MenuCandidate> _menuCandidates;
  late final String _orderCode;

  @override
  void initState() {
    super.initState();
    final initialData = widget.initialData;
    final available = initialData?.availableItems ?? const <FoodCartEntry>[];
    final carts = initialData?.cartItems ?? const <FoodCartEntry>[];

    _items = carts
        .map(
          (item) => _CartItem(
            id: item.id,
            name: item.name,
            price: item.price,
            quantity: item.quantity,
            imageUrl: item.imageUrl,
          ),
        )
        .toList();

    _menuCandidates = available
        .map(
          (item) => _MenuCandidate(
            id: item.id,
            name: item.name,
            price: item.price,
            imageUrl: item.imageUrl,
          ),
        )
        .toList();

    _orderCode =
        initialData?.orderCode ??
        'EBOX-${DateTime.now().millisecondsSinceEpoch % 100000}';
  }

  int get _subtotal =>
      _items.fold<int>(0, (sum, item) => sum + item.totalPrice);

  int get _total => _subtotal + _shippingFee;

  String _formatPrice(int price) =>
      '${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';

  void _increaseQuantity(int index) {
    setState(() {
      final current = _items[index];
      _items[index] = current.copyWith(quantity: current.quantity + 1);
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      final current = _items[index];
      if (current.quantity <= 1) {
        _items.removeAt(index);
        return;
      }
      _items[index] = current.copyWith(quantity: current.quantity - 1);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _clearCart() {
    if (_items.isEmpty) return;
    setState(() {
      _items.clear();
    });
  }

  void _addCandidateToCart(_MenuCandidate candidate) {
    setState(() {
      final existingIndex = _items.indexWhere(
        (item) => item.id == candidate.id,
      );
      if (existingIndex >= 0) {
        final current = _items[existingIndex];
        _items[existingIndex] = current.copyWith(
          quantity: current.quantity + 1,
        );
        return;
      }

      _items.add(
        _CartItem(
          id: candidate.id,
          name: candidate.name,
          price: candidate.price,
          quantity: 1,
          imageUrl: candidate.imageUrl,
        ),
      );
    });
  }

  Future<void> _showAddMoreSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(
                    width: 42,
                    child: Divider(thickness: 4, color: Color(0xFFE2E8F0)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thêm món khác',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final candidate in _menuCandidates) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        candidate.imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      candidate.name,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _formatPrice(candidate.price),
                      style: const TextStyle(
                        color: Color(0xFFEC5B13),
                        fontSize: 13,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: OutlinedButton(
                      onPressed: () {
                        _addCandidateToCart(candidate);
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Thêm'),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _clearCart,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildIntroBanner(),
            const SizedBox(height: 20),
            if (_items.isEmpty)
              _EmptyCartPlaceholder(onAddMore: _showAddMoreSheet)
            else ...[
              for (var index = 0; index < _items.length; index++) ...[
                _CartItemCard(
                  item: _items[index],
                  formatPrice: _formatPrice,
                  onIncrease: () => _increaseQuantity(index),
                  onDecrease: () => _decreaseQuantity(index),
                  onRemove: () => _removeItem(index),
                ),
                if (index < _items.length - 1) const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              _AddMoreButton(onPressed: _showAddMoreSheet),
              const SizedBox(height: 16),
              _SummaryCard(
                subtotal: _subtotal,
                shippingFee: _shippingFee,
                total: _total,
                formatPrice: _formatPrice,
              ),
              const SizedBox(height: 16),
              const _NoteField(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _CheckoutBar(
          total: _total,
          formatPrice: _formatPrice,
          onCheckoutPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => EBoxPaymentSelection(
                  totalAmount: _total,
                  itemCount: _items.fold<int>(
                    0,
                    (count, item) => count + item.quantity,
                  ),
                  orderCode: _orderCode,
                ),
              ),
            );
          },
          isEnabled: _items.isNotEmpty,
        ),
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x19EC5B13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFFEC5B13),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Xem lại các món đã chọn trước khi thanh toán.',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItem {
  final String id;
  final String name;
  final int price;
  final int quantity;
  final String imageUrl;

  const _CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  _CartItem copyWith({
    String? id,
    String? name,
    int? price,
    int? quantity,
    String? imageUrl,
  }) {
    return _CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  int get totalPrice => price * quantity;
}

class _MenuCandidate {
  final String id;
  final String name;
  final int price;
  final String imageUrl;

  const _MenuCandidate({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class _EmptyCartPlaceholder extends StatelessWidget {
  final VoidCallback onAddMore;

  const _EmptyCartPlaceholder({required this.onAddMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 40,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 8),
          const Text(
            'Giỏ hàng đang trống',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hãy thêm món để tiếp tục thanh toán.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _AddMoreButton(onPressed: onAddMore),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final _CartItem item;
  final String Function(int price) formatPrice;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.formatPrice,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(item.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontFamily: 'Aleo',
                          fontWeight: FontWeight.w600,
                          height: 1.38,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onRemove,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(item.price),
                  style: const TextStyle(
                    color: Color(0xFFEC5B13),
                    fontSize: 14,
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 8),
                _QuantityControl(
                  quantity: item.quantity,
                  onIncrease: onIncrease,
                  onDecrease: onDecrease,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityControl({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleActionButton(icon: Icons.remove_rounded, onTap: onDecrease),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ),
          _CircleActionButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF0F172A)),
      ),
    );
  }
}

class _AddMoreButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddMoreButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Thêm món khác'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFEC5B13),
        side: const BorderSide(color: Color(0x33EC5B13)),
        backgroundColor: const Color(0x19EC5B13),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w700,
          height: 1.43,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int subtotal;
  final int shippingFee;
  final int total;
  final String Function(int price) formatPrice;

  const _SummaryCard({
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Tạm tính', value: formatPrice(subtotal)),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Phí giao hàng', value: formatPrice(shippingFee)),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Tổng cộng',
            value: formatPrice(total),
            bold: true,
            valueColor: const Color(0xFFEC5B13),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: bold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            fontSize: bold ? 16 : 14,
            fontFamily: bold ? 'Public Sans' : 'Public Sans',
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            height: bold ? 1.5 : 1.43,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF0F172A),
            fontSize: bold ? 18 : 14,
            fontFamily: 'Aleo',
            fontWeight: FontWeight.w600,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: 1,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Ghi chú cho nhà hàng...',
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEC5B13)),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final int total;
  final String Function(int price) formatPrice;
  final VoidCallback onCheckoutPressed;
  final bool isEnabled;

  const _CheckoutBar({
    required this.total,
    required this.formatPrice,
    required this.onCheckoutPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: isEnabled ? onCheckoutPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEC5B13),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0),
              ),
              const SizedBox(width: 12),
              Text(
                formatPrice(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
