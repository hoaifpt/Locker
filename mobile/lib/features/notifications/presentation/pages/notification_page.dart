import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/injection.dart';
import '../controllers/notification_cubit.dart';
import 'notification_screen.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotificationCubit>(),
      child: const NotificationScreen(),
    );
  }
}
