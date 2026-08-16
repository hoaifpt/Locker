import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/injection.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../controllers/settings_cubit.dart';
import '../controllers/settings_state.dart';
import '../settings_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SettingsCubit>(),
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoggedOut) {
            // SettingsCubit đã xoá token local qua LogoutSettingsUsecase,
            // nhưng AuthGate (main.dart) mới là single source of truth
            // để swap LoginPage <-> HomePage. Trước đây chỉ pushNamedAndRemoveUntil
            // '/login' thủ công — AuthGate vẫn ở AuthAuthenticated (token
            // clearance chưa được AuthCubit biết) → render HomePage trùng
            // route /login → loading kẹt vĩnh viễn.
            //
            // Yêu cầu AuthCubit emit AuthUnauthenticated để AuthGate tự swap.
            context.read<AuthCubit>().logout();
          }
        },
        child: const SettingsScreen(),
      ),
    );
  }
}