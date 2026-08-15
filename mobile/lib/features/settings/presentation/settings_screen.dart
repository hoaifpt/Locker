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
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: switch (state) {
              SettingsLoading() => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF97316),
                ),
              ),
              SettingsError(:final message) => Center(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              SettingsLoaded() => _buildBody(context, state),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SettingsLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildTopBar(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(state.profile),
                const SizedBox(height: 24),
                _AppearanceCard(
                  darkMode: state.darkMode,
                  onDarkModeChanged: context
                      .read<SettingsCubit>()
                      .toggleDarkMode,
                ),
                const SizedBox(height: 16),
                _NotificationCard(
                  notifications: state.notifications,
                  onChanged: (changes) =>
                      context.read<SettingsCubit>().updateNotifications(
                        changes,
                      ),
                ),
                const SizedBox(height: 24),
                const _Footer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          _circleButton(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.settings_rounded,
            size: 20,
            color: Color(0xFFF97316),
          ),
          const SizedBox(width: 8),
          const Text(
            'Cài đặt',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(9999),
            ),
            clipBehavior: Clip.antiAlias,
            child: profile.avatarUrl != null
                ? Image.network(
                    profile.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _avatarFallback(),
                  )
                : _avatarFallback(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isNotEmpty
                      ? profile.name
                      : 'Người dùng',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() => const Icon(
    Icons.person_rounded,
    size: 32,
    color: Color(0xFFF97316),
  );

  Widget _circleButton({VoidCallback? onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─── Appearance card ─────────────────────────────────────────────────────────

class _AppearanceCard extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const _AppearanceCard({
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.monitor_rounded,
                size: 20,
                color: Color(0xFFF97316),
              ),
              SizedBox(width: 8),
              Text(
                'Giao diện',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ToggleRow(
            label: 'Chế độ tối',
            description:
                'Giảm mỏi mắt khi sử dụng trong điều kiện thiếu sáng',
            value: darkMode,
            onChanged: onDarkModeChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Notification card ───────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationPrefs notifications;
  final void Function(Map<String, bool> changes) onChanged;

  const _NotificationCard({
    required this.notifications,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                size: 20,
                color: Color(0xFFF97316),
              ),
              SizedBox(width: 8),
              Text(
                'Thông báo',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ToggleRow(
            label: 'Âm thanh',
            description: 'Phát âm thanh khi có thông báo mới',
            value: notifications.sound,
            onChanged: (v) => onChanged({'sound': v}),
          ),
          const SizedBox(height: 12),
          _ToggleRow(
            label: 'Rung',
            description: 'Rung khi có thông báo mới',
            value: notifications.vibration,
            onChanged: (v) => onChanged({'vibration': v}),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Nhận thông báo về',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _ToggleRow(
            label: 'Cập nhật đơn hàng',
            description: 'Trạng thái đơn hàng, thanh toán',
            value: notifications.orderUpdates,
            onChanged: (v) => onChanged({'orderUpdates': v}),
          ),
          const SizedBox(height: 12),
          _ToggleRow(
            label: 'Cập nhật giao hàng',
            description: 'Thông tin vận chuyển, giao thành công',
            value: notifications.deliveryUpdates,
            onChanged: (v) => onChanged({'deliveryUpdates': v}),
          ),
          const SizedBox(height: 12),
          _ToggleRow(
            label: 'Khuyến mãi',
            description: 'Mã giảm giá, ưu đãi đặc biệt',
            value: notifications.promotions,
            onChanged: (v) => onChanged({'promotions': v}),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFFF97316),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Text(
            'E-Box Locker',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Phiên bản 1.0.0',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: const Color(0xFFE2E8F0)),
  boxShadow: const [
    BoxShadow(
      color: Color(0x0C000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ],
);
