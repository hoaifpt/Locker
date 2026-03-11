import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/settings_repository.dart';
import '../../domain/usecases/get_preferences_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/logout_settings_usecase.dart';
import '../../domain/usecases/update_preferences_usecase.dart';
import '../controllers/settings_cubit.dart';
import '../controllers/settings_state.dart';
import '../settings_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SettingsRepository();
    return BlocProvider(
      create: (_) => SettingsCubit(
        getProfile: GetProfileUsecase(repo),
        getPreferences: GetPreferencesUsecase(repo),
        updatePreferences: UpdatePreferencesUsecase(repo),
        logout: LogoutSettingsUsecase(repo),
      )..load(),
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoggedOut) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        },
        child: const SettingsScreen(),
      ),
    );
  }
}
