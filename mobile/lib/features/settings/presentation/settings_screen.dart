import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/user_profile.dart';
import 'controllers/settings_cubit.dart';
import 'controllers/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFFAF5),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: switch (state) {
                    SettingsLoading() => const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFFF7E5F))),
                    SettingsError(:final message) => Center(
                        child: Text(message,
                            style: const TextStyle(color: Colors.red))),
                    SettingsLoaded() => _buildBody(context, state),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SettingsLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSection(state.profile),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountSettingsCard(),
                const SizedBox(height: 24),
                _buildPreferencesCard(context, state),
                const SizedBox(height: 24),
                _buildSupportCard(),
                const SizedBox(height: 24),
                _buildLogoutButton(context),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Center(
                    child: Text(
                      'Version 2.4.1 (8823)',
                      style: TextStyle(
                        color: Color(0xCC94A3B8),
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xCCFFFAF5),
        border: Border(bottom: BorderSide(color: Color(0xFFFFEDD5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleButton(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_rounded,
                size: 18, color: Color(0xFF334155)),
          ),
          const Text(
            'Settings',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
            ),
          ),
          _circleButton(
            child: const Icon(Icons.notifications_none_rounded,
                size: 20, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  // ─── Profile section ────────────────────────────────────────────────────────

  Widget _buildProfileSection(UserProfile profile) {
    return SizedBox(
      height: 298,
      child: Stack(
        children: [
          // Background gradient
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF7ED), Color(0xFFFFFAF5)],
              ),
            ),
          ),
          // Avatar centered
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 136,
                height: 136,
                child: Stack(
                  children: [
                    // Glow ring
                    Opacity(
                      opacity: 0.30,
                      child: Container(
                        width: 136,
                        height: 136,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
                          ),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                    // Photo
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFFF7E5F), width: 3),
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66FF7E5F),
                              blurRadius: 20,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: profile.avatarUrl != null
                              ? Image.network(
                                  profile.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _avatarFallback(),
                                )
                              : _avatarFallback(),
                        ),
                      ),
                    ),
                    // Camera button
                    Positioned(
                      right: 0,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 16, color: Color(0xFFFF7E5F)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 58,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name : 'Người dùng',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Loyalty badge
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)]),
                  border: Border.all(color: const Color(0x7FFED7AA)),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 2,
                        offset: Offset(0, 1)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: Color(0xFFE06C50)),
                    const SizedBox(width: 8),
                    Text(
                      'Loyalty Member • ${profile.loyaltyPoints} Points',
                      style: const TextStyle(
                        color: Color(0xFFE06C50),
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Cards ──────────────────────────────────────────────────────────────────

  Widget _buildAccountSettingsCard() {
    return _settingsGroup(
      label: 'ACCOUNT SETTINGS',
      child: Column(
        children: [
          _settingRow(
            icon: Icons.person_outline_rounded,
            iconBg: const Color(0xFFFFEDD5),
            iconColor: const Color(0xFFE06C50),
            label: 'Personal Information',
          ),
          _divider(),
          _settingRow(
            icon: Icons.lock_outline_rounded,
            iconBg: const Color(0xFFFFE4E1),
            iconColor: const Color(0xFFE06C50),
            label: 'Security & Privacy',
          ),
          _divider(),
          _settingRow(
            icon: Icons.credit_card_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            label: 'Payment Methods',
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, SettingsLoaded state) {
    final cubit = context.read<SettingsCubit>();
    return _settingsGroup(
      label: 'PREFERENCES',
      child: Column(
        children: [
          _toggleRow(
            icon: Icons.notifications_outlined,
            iconBg: const Color(0xFFFFE4E6),
            iconColor: const Color(0xFFE05E5E),
            label: 'Push Notifications',
            value: state.pushNotifications,
            onChanged: cubit.togglePushNotifications,
          ),
          _divider(),
          _toggleRow(
            icon: Icons.dark_mode_outlined,
            iconBg: const Color(0xFFE0E7FF),
            iconColor: const Color(0xFF6366F1),
            label: 'Dark Mode',
            value: state.darkMode,
            onChanged: cubit.toggleDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return _settingsGroup(
      label: 'SUPPORT',
      child: _settingRow(
        icon: Icons.help_outline_rounded,
        iconBg: const Color(0xFFCCFBF1),
        iconColor: const Color(0xFF0D9488),
        label: 'Help Center',
      ),
    );
  }

  Widget _avatarFallback() => Container(
        color: const Color(0xFFFFEDD5),
        child: const Icon(Icons.person_rounded,
            size: 64, color: Color(0xFFFF7E5F)),
      );

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<SettingsCubit>().logout(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFFEE2E2)),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: const [
            BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 20,
                offset: Offset(0, 4),
                spreadRadius: -2),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B), size: 20),
            Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _settingsGroup({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.20,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x7FFFEDD5)),
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: const [
              BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                  spreadRadius: -2),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _settingRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          spacing: 16,
          children: [
            _iconBox(icon: icon, bg: iconBg, color: iconColor),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFB0BEC5), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        spacing: 16,
        children: [
          _iconBox(icon: icon, bg: iconBg, color: iconColor),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color:
                    value ? const Color(0xFFFF6B6B) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: value ? 24 : 4,
                    top: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 2,
                              offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(
      {required IconData icon, required Color bg, required Color color}) {
    return Container(
      width: 40,
      height: 40,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _circleButton({VoidCallback? onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _divider() => const Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: Color(0xFFF1F5F9),
      );
}
