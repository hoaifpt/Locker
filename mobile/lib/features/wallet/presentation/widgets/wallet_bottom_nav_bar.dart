import 'package:flutter/material.dart';

class WalletBottomNavBar extends StatelessWidget {
  const WalletBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14FB923C),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Trang chủ',
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
          _NavItem(
            icon: Icons.lock_outline_rounded,
            label: 'Lockers',
            onTap: () => Navigator.pushNamed(context, '/lockers'),
          ),
          _NavItem(
            icon: Icons.history_rounded,
            label: 'History',
            active: true,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        active ? const Color(0xFFFB923C) : const Color(0xFFA1A1AA);
    final labelColor =
        active ? const Color(0xFFEA580C) : const Color(0xFFA1A1AA);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFFF7ED) : Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
