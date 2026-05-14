import 'package:flutter/material.dart';

import '../../domain/entities/locker_size.dart';

class LockerSizeCard extends StatelessWidget {
  final LockerSize size;
  final bool isSelected;
  final VoidCallback onTap;

  const LockerSizeCard({
    super.key,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageAsset = switch (size.size.toUpperCase()) {
      'S' => 'assets/Container.png',
      'M' => 'assets/Medium size locker compartment.png',
      'L' => 'assets/Large size locker compartment.png',
      _ => 'assets/Container.png',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            width: isSelected ? 2 : 1,
            color:
                isSelected ? const Color(0xFFFF8E2B) : const Color(0xFFEFEFEF),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 98,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.inventory_2_outlined,
                        size: 34,
                        color: isSelected
                            ? const Color(0xFFFF8E2B)
                            : const Color(0xFFFFB86C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    size.size,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF8E2B)
                          : const Color(0xFF0F172A),
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    size.dimensions,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: -10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8E2B),
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33FF8E2B),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'CHỌN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
