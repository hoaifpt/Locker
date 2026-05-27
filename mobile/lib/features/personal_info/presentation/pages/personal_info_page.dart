import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/personal_info_repository.dart';
import '../../domain/usecases/get_personal_info_overview_usecase.dart';
import '../controllers/personal_info_cubit.dart';
import '../controllers/personal_info_state.dart';
import '../widgets/index.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonalInfoCubit(
        getOverview: GetPersonalInfoOverviewUseCase(
          repository: PersonalInfoRepository(),
        ),
      )..load(),
      child: const _PersonalInfoView(),
    );
  }
}

class _PersonalInfoView extends StatelessWidget {
  const _PersonalInfoView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalInfoCubit, PersonalInfoState>(
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
                      const Icon(Icons.person_off_outlined,
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
                            context.read<PersonalInfoCubit>().load(),
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
                      PersonalInfoHeader(
                        onBack: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
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
                            PersonalInfoAvatarCard(
                              avatarUrl: overview.data.avatarUrl,
                              name: overview.data.fullName,
                              membershipTier: overview.data.membershipTier,
                            ),
                            const SizedBox(height: 24),
                            const PersonalInfoSectionHeader(
                                title: 'THÔNG TIN CÁ NHÂN'),
                            const SizedBox(height: 12),
                            ...overview.items
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: PersonalInfoFieldCard(
                                      label: item.label,
                                      value: item.value,
                                      hint: item.hint,
                                      isEditable: item.isEditable,
                                    ),
                                  ),
                                )
                                ,
                            const SizedBox(height: 12),
                            const PersonalInfoSectionHeader(
                                title: 'QUẢN LÝ TÀI KHOẢN'),
                            const SizedBox(height: 12),
                            ...overview.actions
                                .map(
                                  (action) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: PersonalInfoActionCard(
                                      title: action.title,
                                      subtitle: action.subtitle,
                                      onTap: () => Navigator.pushNamed(
                                          context, action.route),
                                    ),
                                  ),
                                )
                                ,
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFFF7ED),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Thông tin được bảo vệ bởi E-BOX',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF9D4320),
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Mọi thay đổi sẽ được lưu lại sau khi bạn xác nhận.\nBạn luôn có thể quay lại để chỉnh sửa.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF52443E),
                                      fontSize: 14,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w400,
                                      height: 1.63,
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
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Đã lưu thay đổi thông tin cá nhân'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB79D),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              shadowColor: const Color(0x66FFB79D),
                            ),
                            child: const Text(
                              'Lưu thay đổi',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.56,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
