import 'package:flutter/material.dart';

import '../../../food_order/presentation/pages/food_cart_payment_page.dart';
import '../../data/menu_repository.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/usecases/get_menu_usecase.dart';

class MenuPage extends StatefulWidget {
  final String? restaurantId;
  final String? restaurantName;

  const MenuPage({super.key, this.restaurantId,required this.restaurantName,});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  static const List<String> _categories = [
    'Món chính',
    'Đồ uống',
    'Tráng miệng',
  ];

  late final GetMenuUsecase _getMenu;
  late Future<List<MenuItem>> _future;
  int _selectedCategory = 0;
  final Map<String, int> _cartQuantities = {};

  @override
  void initState() {
    super.initState();
    final repo = MenuRepository();
    _getMenu = GetMenuUsecase(repo);
    _future = _getMenu(widget.restaurantId);
  }

  @override
  void didUpdateWidget(covariant MenuPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurantId != widget.restaurantId) {
      _future = _getMenu(widget.restaurantId);
    }
  }

  String _formatPrice(int price) => '${(price / 1000).toStringAsFixed(0)}.000đ';

  int _itemQuantity(String itemId) => _cartQuantities[itemId] ?? 0;

  void _increaseItem(MenuItem item) {
    setState(() {
      _cartQuantities[item.id] = _itemQuantity(item.id) + 1;
    });
  }

  void _decreaseItem(MenuItem item) {
    setState(() {
      final quantity = _itemQuantity(item.id);
      if (quantity <= 1) {
        _cartQuantities.remove(item.id);
      } else {
        _cartQuantities[item.id] = quantity - 1;
      }
    });
  }

  int _cartCount(List<MenuItem> items) {
    return items.fold<int>(0, (sum, item) => sum + _itemQuantity(item.id));
  }

  int _cartTotal(List<MenuItem> items) {
    return items.fold<int>(
      0,
      (sum, item) => sum + (_itemQuantity(item.id) * item.price),
    );
  }

  List<FoodCartEntry> _selectedCartEntries(List<MenuItem> items) {
    return items
        .where((item) => _itemQuantity(item.id) > 0)
        .map(
          (item) => FoodCartEntry(
            id: item.id,
            name: item.name,
            description: item.description,
            price: item.price,
            quantity: _itemQuantity(item.id),
            imageUrl: item.imageUrl,
          ),
        )
        .toList();
  }

  List<FoodCartEntry> _availableEntries(List<MenuItem> items) {
    return items
        .map(
          (item) => FoodCartEntry(
            id: item.id,
            name: item.name,
            description: item.description,
            price: item.price,
            quantity: 1,
            imageUrl: item.imageUrl,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF1A1C1C),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.restaurantName ?? 'Thực đơn',
          style: const TextStyle(
            color: Color(0xFF1A1C1C),
            fontSize: 18,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Không tải được thực đơn',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            );
          }

          final items = snapshot.data ?? const <MenuItem>[];

          return SafeArea(
            top: false,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 220),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Thực đơn',
                        style: TextStyle(
                          color: Color(0xFF1A1C1C),
                          fontSize: 30,
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.75,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bắt đầu ngày mới với hương vị truyền thống\ntinh tế của phố Hội.',
                        style: TextStyle(
                          color: Color(0xFF52443E),
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.63,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildCategoryTabs(),
                      const SizedBox(height: 24),
                      for (final item in items) ...[
                        _buildMenuItemCard(
                          item,
                          quantity: _itemQuantity(item.id),
                          onIncrease: () => _increaseItem(item),
                          onDecrease: () => _decreaseItem(item),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 88,
                  child: _CartSummaryBar(
                    itemCount: _cartCount(items),
                    total: _cartTotal(items),
                    formatPrice: _formatPrice,
                    onCheckoutPressed: () {
                      final selectedItems = _selectedCartEntries(items);
                      if (selectedItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bạn chưa chọn món nào'),
                          ),
                        );
                        return;
                      }

                      Navigator.of(context).pushNamed(
                        '/food-cart-payment',
                        arguments: FoodCartPaymentArgs(
                          cartItems: selectedItems,
                          availableItems: _availableEntries(items),
                          orderCode:
                              'EBOX-${DateTime.now().millisecondsSinceEpoch % 100000}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Row(
      children: [
        for (var index = 0; index < _categories.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: index == _selectedCategory
                      ? const Color(0xFFEC5B13)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: index == _selectedCategory
                        ? const Color(0xFFEC5B13)
                        : const Color(0x26D7C2BB),
                  ),
                  boxShadow: index == _selectedCategory
                      ? const [
                          BoxShadow(
                            color: Color(0x1FEC5B13),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ]
                      : const [],
                ),
                child: Text(
                  _categories[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: index == _selectedCategory
                        ? Colors.white
                        : const Color(0xFF52443E),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    height: 1.43,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMenuItemCard(
    MenuItem item, {
    required int quantity,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x19D7C2BB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFFFFFFF),
            blurRadius: 12,
            offset: Offset(-4, -4),
          ),
          BoxShadow(
            color: Color(0x0A1B1C19),
            blurRadius: 16,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 96,
              height: 96,
              color: const Color(0xFFF3F3F4),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      color: Color(0xFF9E9E9E),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Color(0xFF1A1C1C),
                    fontSize: 18,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF52443E),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.63,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      _formatPrice(item.price),
                      style: const TextStyle(
                        color: Color(0xFFEC5B13),
                        fontSize: 18,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.56,
                      ),
                    ),
                    const Spacer(),
                    if (quantity == 0)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F3F4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: onIncrease,
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFFEC5B13),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QuantityAction(
                              icon: Icons.remove_rounded,
                              onTap: onDecrease,
                            ),
                            SizedBox(
                              width: 24,
                              child: Text(
                                '$quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF1A1C1C),
                                  fontSize: 13,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _QuantityAction(
                              icon: Icons.add_rounded,
                              onTap: onIncrease,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9999),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFFEC5B13)),
      ),
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  final int itemCount;
  final int total;
  final String Function(int price) formatPrice;
  final VoidCallback onCheckoutPressed;

  const _CartSummaryBar({
    required this.itemCount,
    required this.total,
    required this.formatPrice,
    required this.onCheckoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xE51C1917),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8E65),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: const Color(0xFF1C1917), width: 2),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              Positioned(
                right: -4,
                top: -8,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8E65),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: const Color(0xFF1C1917),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Opacity(
                opacity: 0.7,
                child: Text(
                  'TỔNG CỘNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                formatPrice(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onCheckoutPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC5B13),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: const Text(
              'Xem giỏ hàng',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
