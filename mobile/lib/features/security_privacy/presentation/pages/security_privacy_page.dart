import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/security_privacy_repository.dart';
import '../../domain/usecases/get_security_privacy_overview_usecase.dart';
import '../controllers/security_privacy_cubit.dart';
import '../controllers/security_privacy_state.dart';
import '../widgets/index.dart';

class SecurityPrivacyPage extends StatelessWidget {
  const SecurityPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecurityPrivacyCubit(
        getOverview: GetSecurityPrivacyOverviewUseCase(
          repository: SecurityPrivacyRepository(),
        ),
      )..load(),
      child: const _SecurityPrivacyView(),
    );
  }
}

class _SecurityPrivacyView extends StatelessWidget {
  const _SecurityPrivacyView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecurityPrivacyCubit, SecurityPrivacyState>(
      builder: (context, state) {
        if (state.isLoading && state.overview == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9F9F9),
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFB923C)),
              ),
            ),
          );
        }

        if (state.errorMessage != null && state.overview == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 48, color: Color(0xFFFB923C)),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF52443E),
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<SecurityPrivacyCubit>().load(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFB923C),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final overview = state.overview!;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 128),
                  child: Column(
                    children: [
                      SecurityPrivacyHeader(
                        onBack: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/profile',
                              (route) => false,
                            );
                          }
                        },
                        onMore: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const SizedBox(height: 24),
                            const SecurityPrivacySectionHeader(
                                title: 'TRUY CẬP NHANH'),
                            const SizedBox(height: 8),
                            const _QuickAccessGrid(),
                            const SizedBox(height: 24),
                            const SecurityPrivacySectionHeader(
                                title: 'CÀI ĐẶT BẢO VỆ'),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1, color: Colors.white),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0xFFFFFFFF),
                                    blurRadius: 12,
                                    offset: Offset(-4, -4),
                                  ),
                                  BoxShadow(
                                    color: Color(0x0A1A1C1C),
                                    blurRadius: 16,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  SecurityPrivacySettingCard(
                                    title: overview.settings[0].title,
                                    subtitle: overview.settings[0].subtitle,
                                    icon: Icons.face_retouching_natural_rounded,
                                    iconBackground: const Color(0x33FDB69C),
                                    isEnabled: overview.data.faceIdEnabled,
                                    onChanged: (value) {},
                                  ),
                                  Container(
                                    width: 300,
                                    height: 1,
                                    color: const Color(0xFFF3F3F4),
                                  ),
                                  SecurityPrivacySettingCard(
                                    title: overview.settings[1].title,
                                    subtitle: overview.settings[1].subtitle,
                                    icon: Icons.notifications_active_outlined,
                                    iconBackground: const Color(0x33FD8D64),
                                    isEnabled: overview.data.loginAlertEnabled,
                                    onChanged: (value) {},
                                  ),
                                  Container(
                                    width: 300,
                                    height: 1,
                                    color: const Color(0xFFF3F3F4),
                                  ),
                                  SecurityPrivacySettingCard(
                                    title: overview.settings[2].title,
                                    subtitle: overview.settings[2].subtitle,
                                    icon: Icons.shield_outlined,
                                    iconBackground: const Color(0xFFE4E4E7),
                                    isEnabled: overview.data.twoFactorEnabled,
                                    onChanged: (value) {},
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const SecurityPrivacySectionHeader(
                                title: 'QUẢN LÝ TÀI KHOẢN'),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1, color: Colors.white),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0xFFFFFFFF),
                                    blurRadius: 12,
                                    offset: Offset(-4, -4),
                                  ),
                                  BoxShadow(
                                    color: Color(0x0A1A1C1C),
                                    blurRadius: 16,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  SecurityPrivacyActionCard(
                                    title: overview.actions[0].title,
                                    subtitle: overview.actions[0].subtitle,
                                    icon: Icons.password_rounded,
                                    onTap: () {},
                                  ),
                                  Container(
                                    width: 300,
                                    height: 1,
                                    color: const Color(0xFFF3F3F4),
                                  ),
                                  SecurityPrivacyActionCard(
                                    title: overview.actions[1].title,
                                    subtitle: overview.actions[1].subtitle,
                                    icon: Icons.devices_other_rounded,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Align(
                              alignment: Alignment.center,
                              child: SecurityPrivacyPrivacyCard(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SecurityPrivacyBottomNavBar(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _QuickAccessCard(
          icon: Icons.fingerprint_rounded,
          title: 'Xác thực sinh trắc',
          subtitle: 'FaceID đang bật',
          iconBackground: Color(0x33FDB69C),
        ),
        SizedBox(height: 12),
        _QuickAccessCard(
          icon: Icons.sms_outlined,
          title: 'Trạng thái 2FA',
          subtitle: 'Đã kích hoạt qua OTP',
          iconBackground: Color(0x33FD8D64),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackground;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Colors.white),
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFFFFFFFF),
            blurRadius: 12,
            offset: Offset(-4, -4),
          ),
          BoxShadow(
            color: Color(0x0A1A1C1C),
            blurRadius: 16,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: iconBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF1A1C1C)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1A1C1C),
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF52443E),
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}
