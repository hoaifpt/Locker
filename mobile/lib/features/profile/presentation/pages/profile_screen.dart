import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';

class ProfileScreen extends StatefulWidget {
  final GetProfileUsecase getProfile;

  const ProfileScreen({
    super.key,
    required this.getProfile,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.settingsBackground,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<UserProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.settingsAccent,
                ),
              );
            }

            if (snapshot.hasError) {
              return _ProfileErrorState(
                message: _formatError(snapshot.error),
                onRetry: _reload,
              );
            }

            final profile = snapshot.data;
            if (profile == null) {
              return const _ProfileEmptyState();
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SettingsTopBar(
                    title: 'Cài Đặt Tài Khoản',
                    icon: Icons.person_rounded,
                    onBack: () => Navigator.maybePop(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProfileHero(profile: profile),
                        const SizedBox(height: 24),
                        const _ProfileMenuSection(),
                        const SizedBox(height: 16),
                        _LogoutButton(
                          onTap: () => _showLogoutConfirmation(context),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'App Version 2.4.0 (Build 102)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.settingsTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _reload() {
    setState(() {
      _profileFuture = widget.getProfile();
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // Đóng dialog trước để UX không kẹt.
              Navigator.pop(dialogContext);
              // Yêu cầu AuthCubit xóa token + emit AuthUnauthenticated.
              // AuthGate sẽ tự swap sang LoginPage — KHÔNG pushNamedAndRemoveUntil
              // '/login' thủ công vì:
              //   1. AuthGate là single source of truth (line 167 main.dart),
              //   2. Nếu vẫn còn token thì gate vẫn render HomePage đè lên,
              //   3. Trước đây chỉ navigate UI → backend session còn → các
              //      API call sau đó (refresh, profile, ...) trả 401, alert
              //      "phiên đăng nhập hết hạn" và đứng ở loading mãi.
              try {
                await authCubit.logout();
              } catch (e) {
                if (!context.mounted) return;
                await context.showAlertError(e, title: 'Đăng xuất thất bại');
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  String _formatError(Object? error) {
    final message = error?.toString() ?? 'Unknown error';
    return message.startsWith('Exception: ')
        ? message.replaceFirst('Exception: ', '')
        : message;
  }
}

class _ProfileHero extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHero({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: settingsCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.settingsAccentSoft,
              borderRadius: BorderRadius.circular(9999),
            ),
            clipBehavior: Clip.antiAlias,
            child: profile.avatarUrl.isNotEmpty
                ? Image.network(
                    profile.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _AvatarFallback(),
                  )
                : const _AvatarFallback(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.name.isNotEmpty
                            ? profile.name
                            : 'Người dùng',
                        style: const TextStyle(
                          color: AppColors.settingsTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MembershipChip(label: profile.membershipTier),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(
                    color: AppColors.settingsTextSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Points: ',
                        style: TextStyle(
                          color: AppColors.settingsTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: _formatPoints(profile.loyaltyPoints),
                        style: const TextStyle(
                          color: AppColors.settingsAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          icon: Icons.account_balance_wallet_outlined,
          iconBackground: const Color(0xFFFFEDD5),
          title: 'Ví của tôi',
          subtitle: 'Số dư, nạp tiền',
          onTap: () => Navigator.pushNamed(context, '/wallet'),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: Icons.settings_rounded,
          iconBackground: const Color(0xFFEFF6FF),
          title: 'Cài đặt',
          subtitle: 'Giao diện, thông báo',
          onTap: () => Navigator.pushNamed(context, '/settings'),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: Icons.help_outline_rounded,
          iconBackground: const Color(0xFFF0FDF4),
          title: 'FeedBack & Hỗ trợ',
          subtitle: 'Feedback, Support',
          onTap: () async {
            final submitted = await Navigator.pushNamed(context, '/feedback');
            if (!context.mounted || submitted != true) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cảm ơn bạn đã gửi feedback!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.settingsAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.settingsTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.settingsTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.settingsTextMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
        color: const Color(0xFFFEF2F2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 8),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MembershipChip extends StatelessWidget {
  final String label;

  const _MembershipChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.settingsAccentSoft,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.settingsAccent,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.person_rounded,
      size: 36,
      color: AppColors.settingsAccent,
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.settingsAccent,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.settingsTextPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.settingsAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  const _ProfileEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 48,
            color: AppColors.settingsTextMuted,
          ),
          SizedBox(height: 16),
          Text(
            'Không tải được thông tin người dùng',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.settingsTextPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}