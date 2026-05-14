import 'package:flutter/material.dart';

import '../../domain/entities/delivery_package_size.dart';

class DeliveryPackageCard extends StatelessWidget {
  final DeliveryPackageSize packageSize;
  final bool selected;
  final VoidCallback onTap;

  const DeliveryPackageCard({
    super.key,
    required this.packageSize,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFF27B50);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: selected ? 2 : 1,
            color: selected ? accent : const Color(0xFFF1F5F9),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.12)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: selected ? accent : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Size ${packageSize.size}',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    packageSize.description,
                    style: TextStyle(
                      color: selected ? accent : const Color(0xFF64748B),
                      fontSize: 12,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${packageSize.price}đ',
              style: TextStyle(
                color: selected ? accent : const Color(0xFF64748B),
                fontSize: 12,
                fontFamily: 'Manrope',
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
