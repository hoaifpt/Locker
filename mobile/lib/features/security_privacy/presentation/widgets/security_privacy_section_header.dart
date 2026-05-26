import 'package:flutter/material.dart';

class SecurityPrivacySectionHeader extends StatelessWidget {
  final String title;

  const SecurityPrivacySectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF52443E),
          fontSize: 12,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          height: 1.33,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
