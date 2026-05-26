import 'package:flutter/material.dart';

class PersonalInfoSectionHeader extends StatelessWidget {
  final String title;

  const PersonalInfoSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF52443E),
          fontSize: 12,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w700,
          height: 1.33,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}