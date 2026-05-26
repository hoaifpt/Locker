import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';

class NotificationCategory extends StatelessWidget {
  final String categoryTitle;
  final List<NotificationEntity> notifications;
  final Function(NotificationEntity) onNotificationTap;

  const NotificationCategory({
    super.key,
    required this.categoryTitle,
    required this.notifications,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            categoryTitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.33,
              letterSpacing: 0.60,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
