import 'package:flutter/material.dart';

import '../../domain/entities/locker_slot.dart';
import 'locker_cell.dart';

/// Grid sơ đồ tủ — nhóm các slot theo hàng (ký tự đầu của code: A, B, C, D…)
/// Large slot (LockerSize.large) chiếm flex=2 tương đương 2 cột
class LockerGrid extends StatelessWidget {
  final List<LockerSlot> slots;
  final LockerSlot? selectedSlot;
  final ValueChanged<LockerSlot> onSlotTap;

  const LockerGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    // Nhóm slot theo hàng, giữ thứ tự chèn (Dart Map is ordered)
    final rows = <String, List<LockerSlot>>{};
    for (final slot in slots) {
      final key = slot.code[0];
      rows.putIfAbsent(key, () => []).add(slot);
    }

    return Column(
      children: rows.values.map(_buildRow).toList(),
    );
  }

  Widget _buildRow(List<LockerSlot> rowSlots) {
    final children = <Widget>[];
    for (var i = 0; i < rowSlots.length; i++) {
      final slot = rowSlots[i];
      children.add(
        Expanded(
          flex: slot.size == LockerSize.large ? 2 : 1,
          child: LockerCell(
            slot: slot,
            isSelected: selectedSlot?.id == slot.id,
            onTap: () => onSlotTap(slot),
          ),
        ),
      );
      if (i < rowSlots.length - 1) {
        children.add(const SizedBox(width: 16));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: children),
    );
  }
}
