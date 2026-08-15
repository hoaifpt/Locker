import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/injection.dart';
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
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        },
        child: const SettingsScreen(),
      ),
    );
  }
}