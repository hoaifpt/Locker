import 'package:flutter/material.dart';

class PersonalInfoHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;

  const PersonalInfoHeader({
    super.key,
    required this.onBack,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        border: const Border(
          bottom: BorderSide(color: Color(0x19EE8C2B), width: 1),
        ),
      ),
      child: Row(
        children: [
          _HeaderIconButton(onTap: onBack, icon: Icons.arrow_back_ios_new_rounded),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Thông tin cá nhân',
              style: TextStyle(
                color: Color(0xFF1A1C1C),
                fontSize: 18,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.56,
              ),
            ),
          ),
          _HeaderIconButton(onTap: onMore, icon: Icons.more_horiz_rounded),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _HeaderIconButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F3F4),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: const Color(0xFF1A1C1C)),
        ),
      ),
    );
  }
}