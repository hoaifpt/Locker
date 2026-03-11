import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import 'controllers/locker_detail_cubit.dart';
import 'controllers/locker_detail_state.dart';
import 'widgets/activity_timeline.dart';
import 'widgets/locker_image_card.dart';
import 'widgets/locker_stat_card.dart';
import 'widgets/security_setting_row.dart';

/// Màn hình thuần UI — nhận state từ BlocConsumer, không biết gì về DI
class LockerDetailScreen extends StatelessWidget {
  const LockerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LockerDetailCubit, LockerDetailState>(
      listener: (context, state) {
        if (state is LockerDetailOpenSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã mở tủ ${state.lockerCode} thành công!'),
              backgroundColor: AppColors.primary,
            ),
          );
          context.read<LockerDetailCubit>().load();
        } else if (state is LockerDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          context.read<LockerDetailCubit>().load();
        }
      },
      builder: (context, state) {
        if (state is LockerDetailLoading || state is LockerDetailInitial) {
          return const Scaffold(
            backgroundColor: AppColors.warmBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is LockerDetailError) {
          return Scaffold(
            backgroundColor: AppColors.warmBackground,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.primary, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<LockerDetailCubit>().load(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is LockerDetailLoaded) {
          return _LockerDetailBody(state: state);
        }
        return const Scaffold(
          backgroundColor: AppColors.warmBackground,
          body: SizedBox.shrink(),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------
class _LockerDetailBody extends StatelessWidget {
  final LockerDetailLoaded state;
  const _LockerDetailBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LockerDetailCubit>();
    final detail = state.detail;

    return Scaffold(
      backgroundColor: AppColors.warmBackground,
      body: Column(
        children: [
          _LockerDetailHeader(code: detail.code),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Ảnh tủ
                    LockerImageCard(detail: detail),
                    const SizedBox(height: 16),
                    // Stat cards: PIN + CÒN LẠI
                    Row(
                      children: [
                        Expanded(
                          child: LockerStatCard(
                            label: 'PIN',
                            value: '${detail.batteryPercent}%',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: LockerStatCard(
                            label: 'CÒN LẠI',
                            value: '${detail.remainingHours}h',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Cấu hình bảo mật
                    const _SectionTitle(title: 'Cấu hình bảo mật'),
                    const SizedBox(height: 16),
                    SecuritySettingRow(
                      icon: Icons.lock_clock_outlined,
                      title: 'Tự động khóa',
                      subtitle: 'Khóa sau 30 giây',
                      value: detail.isAutoLockEnabled,
                      isUpdating: state.isUpdating,
                      onToggle: cubit.toggleAutoLock,
                    ),
                    const SizedBox(height: 12),
                    SecuritySettingRow(
                      icon: Icons.security_outlined,
                      title: 'Cảnh báo xâm nhập',
                      subtitle: 'Thông báo về điện thoại',
                      value: detail.isIntrusionAlertEnabled,
                      isUpdating: state.isUpdating,
                      onToggle: cubit.toggleIntrusionAlert,
                    ),
                    const SizedBox(height: 24),
                    // Lịch sử hoạt động
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionTitle(title: 'Lịch sử hoạt động'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: ShapeDecoration(
                            color: AppColors.primaryLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Xem tất cả',
                            style: TextStyle(
                              color: Color(0xFFFF7E5F),
                              fontSize: 12,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1, color: Color(0xFFFFF7ED)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child:
                          ActivityTimeline(activities: detail.recentActivities),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _OpenLockerButton(
        isOpening: state.isOpening,
        onTap: cubit.openLocker,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------
class _LockerDetailHeader extends StatelessWidget {
  final String code;
  const _LockerDetailHeader({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 52, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFF8C6B), Color(0xFFFFB347)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Nút back
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          // Tiêu đề
          const Expanded(
            child: Text(
              'Chi tiết ngăn tủ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                letterSpacing: -0.45,
              ),
            ),
          ),
          // Code badge
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Center(
              child: Text(
                code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom CTA button
// ---------------------------------------------------------------------------
class _OpenLockerButton extends StatelessWidget {
  final bool isOpening;
  final VoidCallback onTap;
  const _OpenLockerButton({required this.isOpening, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.warmBackground,
            Color(0xF2FFFAF0),
            Color(0x00FFFAF0)
          ],
        ),
      ),
      child: GestureDetector(
        onTap: isOpening ? null : onTap,
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x4CF97316),
                blurRadius: 10,
                offset: Offset(0, 8),
                spreadRadius: -6,
              ),
              BoxShadow(
                color: Color(0x4CF97316),
                blurRadius: 25,
                offset: Offset(0, 20),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Center(
            child: isOpening
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_open_outlined,
                          color: Colors.white, size: 22),
                      SizedBox(width: 12),
                      Text(
                        'MỞ KHÓA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
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
