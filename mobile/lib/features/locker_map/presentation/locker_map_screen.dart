import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import 'controllers/locker_map_cubit.dart';
import 'controllers/locker_map_state.dart';
import 'widgets/locker_filter_bar.dart';
import 'widgets/locker_grid.dart';
import 'widgets/locker_legend.dart';
import 'widgets/selected_locker_card.dart';

/// Màn hình thuần UI — nhận state từ BlocBuilder, không biết gì về DI
class LockerMapScreen extends StatelessWidget {
  const LockerMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBackground,
      body: BlocConsumer<LockerMapCubit, LockerMapState>(
        listener: (context, state) {
          if (state is LockerOpenSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã mở tủ ${state.lockerCode} thành công!'),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<LockerMapCubit>().load();
          } else if (state is LockerMapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LockerMapLoading || state is LockerMapInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is LockerMapError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.primary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<LockerMapCubit>().load(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          if (state is LockerMapLoaded) {
            return _LockerMapBody(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LockerMapBody extends StatelessWidget {
  final LockerMapLoaded state;
  const _LockerMapBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LockerMapHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _SearchBar(),
                const SizedBox(height: 16),
                LockerFilterBar(
                  activeFilter: state.activeFilter,
                  onFilterChanged: (f) =>
                      context.read<LockerMapCubit>().setFilter(f),
                ),
                const SizedBox(height: 16),
                const LockerLegend(),
                const SizedBox(height: 16),
                LockerGrid(
                  slots: state.slots,
                  selectedSlot: state.selectedSlot,
                  onSlotTap: context.read<LockerMapCubit>().selectSlot,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        if (state.selectedSlot != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SelectedLockerCard(
              slot: state.selectedSlot!,
              isOpening: state.isOpening,
              onOpenTap: () => context.read<LockerMapCubit>().openLocker(),
            ),
          ),
      ],
    );
  }
}

class _LockerMapHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Row(
          children: [
            _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Sơ đồ tủ đồ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.40,
                  letterSpacing: -0.50,
                ),
              ),
            ),
            _CircleIconButton(
              icon: Icons.tune_rounded,
              onTap: () {}, // TODO: mở filter nâng cao
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.primaryLight),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          SizedBox(width: 12),
          Text(
            'Tìm kiếm vị trí tủ...',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút tròn dùng ở header — có thể được tái sử dụng ở màn hình khác
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryLight),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textDark),
      ),
    );
  }
}
