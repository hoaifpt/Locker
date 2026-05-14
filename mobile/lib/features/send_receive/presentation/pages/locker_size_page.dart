import 'package:flutter/material.dart';

import '../../domain/entities/locker_size.dart';
import '../widgets/locker_size_card.dart';

class LockerSizePage extends StatelessWidget {
  final List<LockerSize> sizes;
  final String? selectedSizeId;
  final Function(String) onSizeSelected;

  const LockerSizePage({
    super.key,
    required this.sizes,
    required this.selectedSizeId,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn kích thước ngăn tủ',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 176,
          ),
          itemCount: sizes.length,
          itemBuilder: (context, index) {
            final size = sizes[index];
            return LockerSizeCard(
              size: size,
              isSelected: size.id == selectedSizeId,
              onTap: () => onSizeSelected(size.id),
            );
          },
        ),
      ],
    );
  }
}
