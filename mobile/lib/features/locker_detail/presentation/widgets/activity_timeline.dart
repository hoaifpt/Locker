import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/locker_activity.dart';

/// Danh sách lịch sử hoạt động dạng timeline với dot màu
class ActivityTimeline extends StatelessWidget {
  final List<LockerActivity> activities;
  const ActivityTimeline({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Chưa có hoạt động nào',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (int i = 0; i < activities.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _ActivityItem(activity: activities[i]),
        ],
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final LockerActivity activity;
  const _ActivityItem({required this.activity});

  String _formatTimestamp(DateTime ts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(ts.year, ts.month, ts.day);
    final h12 = ts.hour % 12 == 0 ? 12 : ts.hour % 12;
    final minute = ts.minute.toString().padLeft(2, '0');
    final ampm = ts.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$h12:$minute $ampm';
    if (date == today) return 'Hôm nay, $timeStr';
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == yesterday) return 'Hôm qua, $timeStr';
    return '${ts.day}/${ts.month}/${ts.year}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final dotColor =
        activity.isRecent ? AppColors.primary : const Color(0xFFCBD5E1);
    final ringColor =
        activity.isRecent ? AppColors.primaryLight : const Color(0xFFF1F5F9);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot với ring glow
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: Container(
            width: 12,
            height: 12,
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              shadows: [
                BoxShadow(
                  color: ringColor,
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Container(
              decoration: ShapeDecoration(
                color: dotColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Nội dung
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.action,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(activity.timestamp),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
