import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/notification_repository.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_as_read_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../controllers/notification_cubit.dart';
import 'notification_screen.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = NotificationRepository();

    return BlocProvider(
      create: (context) => NotificationCubit(
        getNotifications: GetNotificationsUsecase(repository: repository),
        markAsRead: MarkAsReadUsecase(repository: repository),
        markAllAsRead: MarkAllAsReadUsecase(repository: repository),
      ),
      child: const NotificationScreen(),
    );
  }
}
