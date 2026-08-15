import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/personal_info_repository.dart';
import '../../domain/usecases/get_personal_info_overview_usecase.dart';
import '../../domain/entities/personal_info_item.dart';
import '../controllers/personal_info_cubit.dart';
import '../controllers/personal_info_state.dart';
import '../widgets/index.dart';
import '../widgets/edit_profile_dialog.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonalInfoCubit(
        getOverview: GetPersonalInfoOverviewUseCase(
          repository: PersonalInfoRepository(),
        ),
        repository: PersonalInfoRepository(),
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
          return Scaffold(
            backgroundColor: AppColors.settingsBackground,
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.settingsAccent,
                ),
              ),
            ),
          );
        }

        if (state.errorMessage != null && state.overview == null) {
          return Scaffold(
            backgroundColor: AppColors.settingsBackground,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_off_outlined,
                        size: 48,
                        color: AppColors.settingsAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.settingsTextPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<PersonalInfoCubit>().load(),
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
              ),
            ),
          );
        }

        final overview = state.overview!;

        return Scaffold(
          backgroundColor: AppColors.settingsBackground,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
                              title: 'THÔNG TIN CÁ NHÂN',
                            ),
                            const SizedBox(height: 12),
                            ...overview.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PersonalInfoFieldCard(
                                  label: item.label,
                                  value: item.value,
                                  hint: item.hint,
                                  isEditable: item.isEditable,
                                  onTap: item.isEditable
                                      ? () => _showEditDialog(context, item)
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const PersonalInfoSectionHeader(
                              title: 'QUẢN LÝ TÀI KHOẢN',
                            ),
                            const SizedBox(height: 12),
                            ...overview.actions.map(
                              (action) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PersonalInfoActionCard(
                                  title: action.title,
                                  subtitle: action.subtitle,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    action.route,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.settingsAccentSoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Thông tin được bảo vệ bởi E-BOX',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.settingsAccent,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Mọi thay đổi sẽ được lưu lại sau khi bạn xác nhận.\nBạn luôn có thể quay lại để chỉnh sửa.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.settingsTextSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
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
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Đã lưu thay đổi thông tin cá nhân',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.settingsAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

  void _showEditDialog(BuildContext context, PersonalInfoItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PersonalInfoCubit>(),
        child: EditProfileDialog(
          title: 'Chỉnh sửa ${item.label}',
          initialValue: item.value,
          label: item.label,
          isLoading: context.watch<PersonalInfoCubit>().state.isUpdating,
          onSave: (newValue) async {
            if (item.label == 'HỌ VÀ TÊN') {
              context.read<PersonalInfoCubit>().updateProfile(
                fullName: newValue,
              );
            } else if (item.label == 'EMAIL') {
              context.read<PersonalInfoCubit>().updateProfile(email: newValue);
            } else if (item.label == 'SỐ ĐIỆN THOẠI') {
              context.read<PersonalInfoCubit>().updateProfile(
                phoneNumber: newValue,
              );
            }
          },
        ),
      ),
    );
  }
}