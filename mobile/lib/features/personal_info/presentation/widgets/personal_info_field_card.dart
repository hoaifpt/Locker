import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PersonalInfoFieldCard extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final bool isEditable;
  final VoidCallback? onTap;

  const PersonalInfoFieldCard({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.isEditable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: settingsCardDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.settingsTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.settingsTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hint.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          hint,
                          style: const TextStyle(
                            color: AppColors.settingsTextMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isEditable)
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.settingsAccent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}