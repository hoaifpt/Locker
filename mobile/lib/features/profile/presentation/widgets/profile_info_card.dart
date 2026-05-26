import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserProfile userProfile;

  const ProfileInfoCard({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFF1E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with border
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x33EE8C2B),
              border: Border.all(
                color: const Color(0xFFFFE4CC),
                width: 4,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF7ED),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 64,
                  color: Color(0xFFFB923C),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Name
          Text(
            userProfile.name,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          // Membership tier
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x19EE8C2B),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              userProfile.membershipTier,
              style: const TextStyle(
                color: Color(0xFFEE8C2B),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Points
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Points: ',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: '${userProfile.loyaltyPoints}',
                  style: const TextStyle(
                    color: Color(0xFFEE8C2B),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Email and Phone
          Column(
            children: [
              _InfoRow(label: 'Email', value: userProfile.email),
              const SizedBox(height: 8),
              _InfoRow(label: 'Phone', value: userProfile.phoneNumber),
              const SizedBox(height: 8),
              _InfoRow(label: 'Address', value: userProfile.address),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
