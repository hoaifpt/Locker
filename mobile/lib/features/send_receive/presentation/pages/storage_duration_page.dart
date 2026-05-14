import 'package:flutter/material.dart';

import '../../domain/entities/storage_duration.dart';
import '../widgets/duration_button.dart';

class StorageDurationPage extends StatelessWidget {
  final List<StorageDuration> durations;
  final String? selectedDurationId;
  final Function(String) onDurationSelected;

  const StorageDurationPage({
    super.key,
    required this.durations,
    required this.selectedDurationId,
    required this.onDurationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thời gian gửi',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final duration in durations)
              DurationButton(
                duration: duration,
                isSelected: duration.id == selectedDurationId,
                onTap: () => onDurationSelected(duration.id),
              ),
          ],
        ),
      ],
    );
  }
}
