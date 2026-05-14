import 'package:flutter/material.dart';

class DeliverySectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  const DeliverySectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: Color(0xFFF27B50),
              fontSize: 14,
              fontFamily: 'Aleo',
              fontWeight: FontWeight.w600,
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }
}
