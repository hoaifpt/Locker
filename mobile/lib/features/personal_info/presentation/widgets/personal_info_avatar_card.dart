import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PersonalInfoAvatarCard extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String membershipTier;

  const PersonalInfoAvatarCard({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.membershipTier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: settingsCardDecoration(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.settingsAccentSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.settingsAccent,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipOval(
                  child: avatarUrl.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 56,
                            color: AppColors.settingsAccent,
                          ),
                        )
                      : Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 56,
                              color: AppColors.settingsAccent,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.settingsCardBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.settingsShadow,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: AppColors.settingsAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.settingsTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.settingsAccentSoft,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              membershipTier,
              style: const TextStyle(
                color: AppColors.settingsAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}