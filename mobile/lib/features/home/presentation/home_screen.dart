import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../locker/domain/entities/locker.dart';
import '../domain/entities/user.dart';
import '../domain/entities/active_locker.dart';
import 'controllers/home_cubit.dart';
import 'controllers/home_state.dart';
import 'widgets/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial || state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFB923C)),
              );
            }

            if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<HomeCubit>().load(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFB923C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loaded = state as HomeLoaded;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HomeHeader(
                    user: loaded.user,
                    onProfileTap: () {
                      Navigator.pushNamed(context, '/personal-info');
                    },
                    onNotificationsTap: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: HomeSearchBar(
                      hintText: 'Tìm dịch vụ hoặc vị trí tủ...',
                      onTap: () {},
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'Dịch vụ của E-BOX',
                    child: SizedBox(
                      height: 136,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: _services.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return ServiceCard(
                            label: service.label,
                            icon: service.icon,
                            onTap: () {
                              if (service.route != null) {
                                Navigator.pushNamed(context, service.route!);
                              } else {
                                service.onTap();
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'Tủ bạn đang dùng',
                    trailing: Text(
                      'Tất cả (${loaded.activeLockers.length})',
                      style: const TextStyle(
                        color: Color(0xFFFB923C),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _ActiveLockerSection(
                        activeLockers: loaded.activeLockers,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'Gợi ý tủ gần đây',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _NearbyLockerList(
                        nearbyLockers: loaded.nearbyLockers,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final User user;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  const _HomeHeader({
    required this.user,
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF7ED), Color(0xFFFFFBF2)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: user.avatarUrl != null
                        ? Image.network(
                            user.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Color(0xFFFB923C),
                            ),
                          )
                        : const Icon(Icons.person, color: Color(0xFFFB923C)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào, ${user.fullName}!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Hồ Chí Minh',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onNotificationsTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14FB923C),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFB923C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Section({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ActiveLockerSection extends StatelessWidget {
  final List<ActiveLocker> activeLockers;

  const _ActiveLockerSection({required this.activeLockers});

  @override
  Widget build(BuildContext context) {
    if (activeLockers.isEmpty) {
      return const _EmptyCard(
        icon: Icons.lock_outline_rounded,
        title: 'Chưa có tủ đang dùng',
        description: 'Các tủ đã thuê sẽ xuất hiện ở đây.',
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activeLockers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final locker = activeLockers[index];
          return SizedBox(width: 300, child: _ActiveLockerCard(locker: locker));
        },
      ),
    );
  }
}

class _ActiveLockerCard extends StatelessWidget {
  final ActiveLocker locker;

  const _ActiveLockerCard({required this.locker});

  @override
  Widget build(BuildContext context) {
    final isActive = locker.status.toLowerCase() == 'active';

    return Container(
      height: 220,
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFEFFAF3)
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        locker.status.toUpperCase(),
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFEA580C),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      locker.code,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locker.location.isEmpty
                          ? 'Cập nhật vị trí sau'
                          : locker.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF7ED),
                  border: Border.all(color: const Color(0xFFFFE4CC)),
                ),
                child: Center(
                  child: Text(
                    '${(locker.usagePercent * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFFFB923C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFFFB923C),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Còn lại',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      locker.timeRemaining.isEmpty
                          ? '--:--'
                          : locker.timeRemaining,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFB923C),
                side: const BorderSide(color: Color(0xFFFB923C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.lock_open_rounded, size: 18),
              label: const Text(
                'Mở khóa',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
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

class _NearbyLockerList extends StatelessWidget {
  final List<Locker> nearbyLockers;

  const _NearbyLockerList({required this.nearbyLockers});

  @override
  Widget build(BuildContext context) {
    if (nearbyLockers.isEmpty) {
      return const _EmptyCard(
        icon: Icons.location_on_outlined,
        title: 'Chưa có gợi ý tủ gần đây',
        description: 'Các tủ khả dụng gần bạn sẽ hiển thị ở đây.',
      );
    }

    return Column(
      children: [
        for (final locker in nearbyLockers) ...[
          _NearbyLockerTile(locker: locker),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _NearbyLockerTile extends StatelessWidget {
  final Locker locker;

  const _NearbyLockerTile({required this.locker});

  @override
  Widget build(BuildContext context) {
    final hasLocation = locker.location.trim().isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/locker-detail', arguments: locker.id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Color(0xFFFB923C),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locker.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasLocation ? locker.location : 'Khu vực khả dụng gần bạn',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFF1E8)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFB923C), size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14FB923C),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.home_rounded,
            label: 'Trang chủ',
            active: true,
          ),
          _BottomNavItem(
            icon: Icons.receipt_long_outlined,
            label: 'Đơn hàng',
            routeName: '/orders',
          ),
          _BottomNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Tài khoản',
            routeName: '/profile',
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final String? routeName;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = active
        ? const Color(0xFFFB923C)
        : const Color(0xFF94A3B8);
    final labelColor = active
        ? const Color(0xFFFB923C)
        : const Color(0xFF94A3B8);

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFF7ED) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
            fontFamily: 'Inter',
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );

    if (routeName == null) {
      return child;
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(routeName!),
      child: child,
    );
  }
}

class _ServiceItem {
  final String label;
  final IconData icon;
  final String? route;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.label,
    required this.icon,
    this.route,
    required this.onTap,
  });
}

final List<_ServiceItem> _services = [
  const _ServiceItem(
    label: 'Giao Nhận Đồ',
    icon: Icons.local_shipping_outlined,
    route: '/delivery',
    onTap: _noop,
  ),
  const _ServiceItem(
    label: 'Đặt Đồ Ăn',
    icon: Icons.restaurant_outlined,
    route: '/food-order',
    onTap: _noop,
  ),
  const _ServiceItem(
    label: 'Gửi Nhận Đồ',
    icon: Icons.move_to_inbox_outlined,
    route: '/send-receive',
    onTap: _noop,
  ),
  const _ServiceItem(
    label: 'Ví E-BOX',
    icon: Icons.account_balance_wallet_outlined,
    route: '/wallet',
    onTap: _noop,
  ),
];

void _noop() {}
