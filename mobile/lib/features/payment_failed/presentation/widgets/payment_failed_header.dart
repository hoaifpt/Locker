import 'package:flutter/material.dart';

class PaymentFailedHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;

  const PaymentFailedHeader({
    super.key,
    required this.onBack,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: Row(
        children: [
          _CircleIconButton(
              onTap: onBack, icon: Icons.arrow_back_ios_new_rounded),
          const Spacer(),
          _CircleIconButton(onTap: onMore, icon: Icons.more_horiz_rounded),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _CircleIconButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }
}
