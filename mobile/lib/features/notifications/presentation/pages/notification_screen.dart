import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification.dart';
import '../controllers/notification_cubit.dart';
import '../controllers/notification_state.dart';
import '../widgets/index.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFF27B50)),
              );
            }

            if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Color(0xFFF27B50),
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                  ],
                ),
              );
            }

            if (state is NotificationLoaded) {
              final notifications = state.notifications;

              // Group notifications by category
              final Map<String, List<NotificationEntity>> groupedNotifications =
                  {};
              for (var notification in notifications) {
                if (!groupedNotifications.containsKey(notification.category)) {
                  groupedNotifications[notification.category] = [];
                }
                groupedNotifications[notification.category]!.add(notification);
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    NotificationHeader(
                      onBackToHome: () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/home', (route) => false);
                      },
                      onMarkAllAsRead: () {
                        context
                            .read<NotificationCubit>()
                            .markAllNotificationsAsRead();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final category
                              in groupedNotifications.keys.toList()..sort())
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.60,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  spacing: 16,
                                  children: [
                                    for (final notification
                                        in groupedNotifications[category]!)
                                      NotificationItem(
                                        notification: notification,
                                        onTap: () {
                                          context
                                              .read<NotificationCubit>()
                                              .markNotificationAsRead(
                                                notification.id,
                                              );

                                          if (notification.category ==
                                                  'DELIVERY' &&
                                              notification.metadata != null) {
                                            final lockerId =
                                                notification
                                                        .metadata!['lockerId']
                                                    as String;
                                            final slotIndex =
                                                notification
                                                        .metadata!['slotIndex']
                                                    as int;
                                          }
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('No notifications'));
          },
        ),
      ),
    );
  }
}
