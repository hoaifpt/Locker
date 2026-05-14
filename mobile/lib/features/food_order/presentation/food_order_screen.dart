import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'controllers/food_order_cubit.dart';
import 'controllers/food_order_state.dart';
import 'widgets/restaurant_bottom_sheet.dart';
import 'widgets/restaurant_pin_widget.dart';

class FoodOrderScreen extends StatelessWidget {
  const FoodOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: BlocBuilder<FoodOrderCubit, FoodOrderState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFD8D64)),
              );
            }

            final selected = state.selectedRestaurant;
            if (selected == null) {
              return const Center(child: Text('Không có quán ăn gần đây'));
            }

            return Stack(
              children: [
                _MapLayer(
                  state: state,
                  onSelect: (id) =>
                      context.read<FoodOrderCubit>().selectRestaurant(id),
                ),
                const _TopOverlay(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: RestaurantBottomSheet(restaurant: selected),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopOverlay extends StatelessWidget {
  const _TopOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white.withValues(alpha: 0.70),
      child: Column(
        children: [
          Row(
            children: [
              _circleIconButton(
                  Icons.arrow_back_rounded, () => Navigator.pop(context)),
              const Spacer(),
              const Text(
                'Bản đồ',
                style: TextStyle(
                  color: Color(0xFF1A1C1C),
                  fontSize: 20,
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _circleIconButton(Icons.tune_rounded, () {}),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: Color(0xFF85736D)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tìm quán ăn sáng...',
                          style: TextStyle(
                            color: Color(0xFF85736D),
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFD8D64),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.my_location_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F3F4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1A1C1C)),
      ),
    );
  }
}

class _MapLayer extends StatelessWidget {
  final FoodOrderState state;
  final ValueChanged<String> onSelect;

  const _MapLayer({required this.state, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapHeight = constraints.maxHeight;
        return Stack(
          children: [
            Container(color: const Color(0xFFF9F9F9)),
            Positioned.fill(child: CustomPaint(painter: _RoadPainter())),
            for (final restaurant in state.restaurants)
              Positioned(
                left: constraints.maxWidth * restaurant.offsetX,
                top: mapHeight * restaurant.offsetY,
                child: RestaurantPinWidget(
                  label: restaurant.name,
                  selected: state.selectedRestaurantId == restaurant.id,
                  onTap: () => onSelect(restaurant.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = const Color(0xFFE7E7E7)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final major = Path()
      ..moveTo(size.width * 0.10, size.height * 0.20)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.28,
          size.width * 0.80, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.60, size.height * 0.52,
          size.width * 0.25, size.height * 0.60)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.63,
          size.width * 0.08, size.height * 0.75);
    canvas.drawPath(major, road);

    final road2 = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final minor = Path()
      ..moveTo(size.width * 0.75, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.30,
          size.width * 0.58, size.height * 0.42)
      ..quadraticBezierTo(size.width * 0.49, size.height * 0.55,
          size.width * 0.45, size.height * 0.70);
    canvas.drawPath(minor, road2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
