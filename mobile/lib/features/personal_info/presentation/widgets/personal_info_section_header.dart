import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
          color: AppColors.settingsTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}