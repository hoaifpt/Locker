import 'package:equatable/equatable.dart';

import 'locker_slot.dart';

/// Pure domain entity - không phụ thuộc framework hay data layer
class Locker extends Equatable {
  final String id;
  final String name;
  final String location;
  final List<LockerSlot> slots;

  const Locker({
    required this.id,
    required this.name,
    this.location = '',
    this.slots = const [],
  });

  // Dùng cho trường hợp orElse trong UI
  static const Locker empty = Locker(
    id: '',
    name: 'N/A',
    location: '',
    slots: [],
  );

  @override
  List<Object?> get props => [id, name, location, slots];
}
