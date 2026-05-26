import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  Color get _iconBackgroundColor {
    switch (notification.iconType) {
      case 'success':
        return const Color(0x0CF27B50);
      case 'warning':
        return const Color(0x0CF27B50);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  IconData get _icon {
    switch (notification.iconType) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.local_shipping_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: notification.isRead
              ? const Color(0xFFF8FAFC)
              : const Color(0x0CF27B50),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: notification.isRead
                  ? const Color(0xFFF1F5F9)
                  : const Color(0x19F27B50),
            ),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: notification.isRead
                        ? const Color(0xFFF1F5F9)
                        : const Color(0x0CF27B50),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  _icon,
                  color: const Color(0xFFF27B50),
                  size: 24,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2.8,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                  Text(
                    notification.description,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w400,
                      height: 1.63,
                    ),
                  ),
                  Text(
                    notification.timestamp,
                    style: TextStyle(
                      color: notification.isRead
                          ? const Color(0xFF94A3B8)
                          : const Color(0xB2F27B50),
                      fontSize: 11,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Positioned(
                right: 20,
                top: 20,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFF27B50),
                    shape: OvalBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
