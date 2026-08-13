import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFFF8F7F6),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<UserProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFEE8C2B)),
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

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileTopBar(
                    title: 'Cài Đặt Tài Khoản',
                    onBack: () => Navigator.maybePop(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProfileHero(profile: profile),
                        const SizedBox(height: 24),
                        const _ProfileMenuSection(),
                        const SizedBox(height: 32),
                        _LogoutButton(
                          onTap: () => _showLogoutConfirmation(context),
                        ),
                        const SizedBox(height: 24),
                        const Center(
                          child: Text(
                            'App Version 2.4.0 (Build 102)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
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

class _ProfileTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _ProfileTopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xE5F8F7F6),
        border: Border(
          bottom: BorderSide(color: Color(0x19EE8C2B), width: 1),
        ),
      ),
      child: Row(
        children: [
          _IconCircleButton(onTap: onBack, icon: Icons.arrow_back_ios_new),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                height: 1.56,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHero({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 232,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: _AvatarRing(imageUrl: profile.avatarUrl),
          ),
          Positioned(
            top: 144,
            child: Text(
              profile.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 24,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
          ),
          Positioned(
            top: 180,
            child: _MembershipChip(label: profile.membershipTier),
          ),
          Positioned(
            top: 212,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Points: ',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                  TextSpan(
                    text: _formatPoints(profile.loyaltyPoints),
                    style: const TextStyle(
                      color: Color(0xFFEE8C2B),
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.43,
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

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }
}

class _AvatarRing extends StatelessWidget {
  final String imageUrl;

  const _AvatarRing({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 128,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x33EE8C2B),
        border: Border.all(color: const Color(0xFFF8F7F6), width: 4),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF8F7F6),
          border: Border.all(color: const Color(0xFFF8F7F6), width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _AvatarImage(imageUrl: imageUrl),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String imageUrl;

  const _AvatarImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.person_rounded, size: 64, color: Color(0xFFEE8C2B)),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.person_rounded, size: 64, color: Color(0xFFEE8C2B)),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

class _MembershipChip extends StatelessWidget {
  final String label;

  const _MembershipChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x19EE8C2B),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFEE8C2B),
          fontSize: 12,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w700,
          height: 1.33,
          letterSpacing: 0.6,
        ),
      ),
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
          subtitle: 'Manage payment methods',
          onTap: () => Navigator.pushNamed(context, '/wallet'),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: Icons.lock_outline_rounded,
          iconBackground: const Color(0xFFEFF6FF),
          title: 'Bảo mật',
          subtitle: 'Password, FaceID',
          onTap: () => Navigator.pushNamed(context, '/security-privacy'),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(48),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(48),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(icon, color: const Color(0xFFEE8C2B), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
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
    return Material(
      color: const Color(0x7FFEF2F2),
      borderRadius: BorderRadius.circular(48),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(48),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 8),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
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
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEE8C2B)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE8C2B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
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
          Icon(Icons.person_off_outlined, size: 48, color: Color(0xFF94A3B8)),
          SizedBox(height: 16),
          Text(
            'Không tải được thông tin người dùng',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _IconCircleButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x190F172A)),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF0F172A)),
        ),
      ),
    );
  }
}
