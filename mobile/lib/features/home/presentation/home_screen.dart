import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../locker/domain/entities/locker.dart';
import '../domain/entities/active_locker.dart';
import 'controllers/home_cubit.dart';
import 'controllers/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EC),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial || state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF7E5F)),
              );
            }

            if (state is HomeError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<HomeCubit>().load(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            final loaded = state as HomeLoaded;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          title: 'Tủ bạn đang dùng',
                          trailing: GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/lockers'),
                            child: Text(
                              'Tất cả (${loaded.activeLockers.length})',
                              style: const TextStyle(
                                color: Color(0xFFFF7E5F),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActiveLockersList(loaded.activeLockers),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          title: 'Gợi ý tủ gần đây',
                          trailing: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        _buildNearbyLockersList(context, loaded.nearbyLockers),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: _buildBottomNav(context),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(color: Color(0xE5FFF5EC)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 12,
            children: [
              // Avatar with gradient ring
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0, 0),
                    end: Alignment(1, 1),
                    colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.network(
                      'https://placehold.co/36x36',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 20,
                        color: Color(0xFFFF7E5F),
                      ),
                    ),
                  ),
                ),
              ),
              // Greeting text
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào buổi sáng,',
                    style: TextStyle(
                      color: Color(0xFF8B5E3C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Nguyễn Minh',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // City badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.60),
              border: Border.all(color: const Color(0xFFFFEDD5)),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Row(
              spacing: 6,
              children: [
                Icon(Icons.location_on, size: 14, color: Color(0xFFFF7E5F)),
                Text(
                  'Hồ Chí Minh',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      spacing: 16,
      children: [
        // QR Scan
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.03, -0.04),
                  end: Alignment(0.97, 1.04),
                  colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33FF7E5F),
                    blurRadius: 40,
                    offset: Offset(0, 10),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: const Column(
                spacing: 12,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0x33FFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        border: Border.fromBorderSide(
                          BorderSide(color: Color(0x4DFFFFFF)),
                        ),
                      ),
                      child: Icon(Icons.qr_code_scanner,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  Text(
                    'Quét QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Enter code
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x33FF7E5F), width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 2,
                      offset: Offset(0, 1)),
                ],
              ),
              child: const Column(
                spacing: 12,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Icon(Icons.dialpad,
                          color: Color(0xFFFF7E5F), size: 28),
                    ),
                  ),
                  Text(
                    'Nhập mã tủ',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      {required String title, required Widget trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing,
      ],
    );
  }

  static const _mockActiveLockers = [
    _ActiveLockerData(
      code: 'Locker A-102',
      location: 'Cơ sở Quận 1',
      statusLabel: 'ACTIVE',
      statusDotColor: Color(0xFF22C55E),
      statusBgColor: Color(0xFFF0FDF4),
      statusTextColor: Color(0xFF16A34A),
      usagePercent: 0.75,
      usageLabel: '75%',
      timeRemaining: '02h 45m',
      timeBgColor: Color(0xFFFFF5EC),
      isGradientButton: true,
    ),
    _ActiveLockerData(
      code: 'Locker B-205',
      location: 'Cơ sở Thủ Đức',
      statusLabel: 'ACTIVE',
      statusDotColor: Color(0xFFF97316),
      statusBgColor: Color(0xFFFFF7ED),
      statusTextColor: Color(0xFFEA580C),
      usagePercent: 0.30,
      usageLabel: '30%',
      timeRemaining: '15h 20m',
      timeBgColor: Color(0xFFF8FAFC),
      isGradientButton: false,
    ),
  ];

  _ActiveLockerData _toCardData(ActiveLocker locker, int index) {
    final isFirst = index == 0;
    return _ActiveLockerData(
      code: locker.code,
      location: locker.location,
      statusLabel: locker.status,
      statusDotColor:
          isFirst ? const Color(0xFF22C55E) : const Color(0xFFF97316),
      statusBgColor:
          isFirst ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
      statusTextColor:
          isFirst ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
      usagePercent: locker.usagePercent,
      usageLabel: '${(locker.usagePercent * 100).toInt()}%',
      timeRemaining: locker.timeRemaining,
      timeBgColor: isFirst ? const Color(0xFFFFF5EC) : const Color(0xFFF8FAFC),
      isGradientButton: isFirst,
    );
  }

  Widget _buildActiveLockersList(List<ActiveLocker> activeLockers) {
    final cards = activeLockers.isNotEmpty
        ? activeLockers
            .asMap()
            .entries
            .map((e) => _toCardData(e.value, e.key))
            .toList()
        : _mockActiveLockers;

    return SizedBox(
      height: 254,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: cards.length,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(right: i < cards.length - 1 ? 16 : 0),
          child: _ActiveLockerCard(data: cards[i]),
        ),
      ),
    );
  }

  Widget _buildNearbyLockersList(
      BuildContext context, List<Locker> nearbyLockers) {
    final items = nearbyLockers.isNotEmpty
        ? nearbyLockers
            .map((l) => (
                  name: l.code,
                  distance: l.location.isNotEmpty ? l.location : 'Gần đây',
                  slots: l.isOccupied ? 0 : 1,
                ))
            .toList()
        : [
            (name: 'Hub Trung tâm Crescent', distance: '450m', slots: 12),
            (name: 'Vincom Landmark 81', distance: '1.2km', slots: 5),
          ];

    return Column(
      spacing: 12,
      children: items
          .map((item) => _NearbyLockerCard(
                name: item.name,
                distance: item.distance,
                availableSlots: item.slots,
                onTap: () => Navigator.pushNamed(context, '/lockers'),
              ))
          .toList(),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.50)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x26FF7E5F), blurRadius: 32, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home — active
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
              ),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.home_rounded, color: Colors.white, size: 22),
          ),
          _navIcon(Icons.search_rounded),
          Stack(
            children: [
              _navIcon(Icons.notifications_none_rounded),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          _navIcon(Icons.qr_code_rounded),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: _navIcon(Icons.person_outline_rounded),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
    );
  }
}

// ─── Data models ───────────────────────────────────────────────────────────────

class _ActiveLockerData {
  final String code, location, statusLabel, usageLabel, timeRemaining;
  final Color statusDotColor, statusBgColor, statusTextColor, timeBgColor;
  final double usagePercent;
  final bool isGradientButton;

  const _ActiveLockerData({
    required this.code,
    required this.location,
    required this.statusLabel,
    required this.statusDotColor,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.usagePercent,
    required this.usageLabel,
    required this.timeRemaining,
    required this.timeBgColor,
    required this.isGradientButton,
  });
}

// ─── Active locker card ────────────────────────────────────────────────────────

class _ActiveLockerCard extends StatelessWidget {
  final _ActiveLockerData data;
  const _ActiveLockerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x7FFFEDD5)),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
              color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + name + usage circle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: data.statusBgColor,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: data.statusDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          data.statusLabel,
                          style: TextStyle(
                            color: data.statusTextColor,
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.code,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    data.location,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Usage circle
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: data.usagePercent,
                      strokeWidth: 4.67,
                      backgroundColor: const Color(0xFFFFEDD5),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFFFF7E5F)),
                    ),
                    Text(
                      data.usageLabel,
                      style: const TextStyle(
                        color: Color(0xFFFF7E5F),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Time remaining
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.timeBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 16, color: Color(0xFFFF7E5F)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'THỜI GIAN CÒN LẠI',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.50,
                      ),
                    ),
                    Text(
                      data.timeRemaining,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Unlock button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: data.isGradientButton
                    ? const LinearGradient(
                        colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
                      )
                    : null,
                color: data.isGradientButton ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: data.isGradientButton
                    ? null
                    : Border.all(color: const Color(0xFFFF7E5F)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(
                    Icons.lock_open_rounded,
                    size: 16,
                    color: data.isGradientButton
                        ? Colors.white
                        : const Color(0xFFFF7E5F),
                  ),
                  Text(
                    'Mở khóa',
                    style: TextStyle(
                      color: data.isGradientButton
                          ? Colors.white
                          : const Color(0xFFFF7E5F),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
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

// ─── Nearby locker card ────────────────────────────────────────────────────────

class _NearbyLockerCard extends StatelessWidget {
  final String name, distance;
  final int availableSlots;
  final VoidCallback onTap;

  const _NearbyLockerCard({
    required this.name,
    required this.distance,
    required this.availableSlots,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
                color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          spacing: 16,
          children: [
            // Thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.inbox_rounded,
                      size: 32, color: Color(0xFFFF7E5F)),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.40),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            const Icon(Icons.location_on,
                                size: 10, color: Color(0xFFEA580C)),
                            Text(
                              distance,
                              style: const TextStyle(
                                color: Color(0xFFEA580C),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$availableSlots ô trống',
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFEDD5)),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 2,
                      offset: Offset(0, 1)),
                ],
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFFF7E5F),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
