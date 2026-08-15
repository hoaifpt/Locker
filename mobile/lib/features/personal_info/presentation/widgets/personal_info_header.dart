import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PersonalInfoHeader extends StatelessWidget {
  final VoidCallback onBack;

  const PersonalInfoHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SettingsTopBar(
      title: 'Thông tin cá nhân',
      icon: Icons.person_outline_rounded,
      onBack: onBack,
    );
  }
}