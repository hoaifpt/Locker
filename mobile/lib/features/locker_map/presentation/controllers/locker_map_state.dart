import 'package:equatable/equatable.dart';

import '../../domain/entities/locker_slot.dart';

enum LockerFilter { nearest, large, small }

abstract class LockerMapState extends Equatable {
  const LockerMapState();
  @override
  List<Object?> get props => [];
}

class LockerMapInitial extends LockerMapState {
  const LockerMapInitial();
}

class LockerMapLoading extends LockerMapState {
  const LockerMapLoading();
}

class LockerMapLoaded extends LockerMapState {
  final List<LockerSlot> slots;
  final LockerSlot? selectedSlot;
  final LockerFilter activeFilter;
  final bool isOpening;

  const LockerMapLoaded({
    required this.slots,
    this.selectedSlot,
    this.activeFilter = LockerFilter.nearest,
    this.isOpening = false,
  });

  LockerMapLoaded copyWith({
    List<LockerSlot>? slots,
    LockerSlot? selectedSlot,
    bool clearSelected = false,
    LockerFilter? activeFilter,
    bool? isOpening,
  }) {
    return LockerMapLoaded(
      slots: slots ?? this.slots,
      selectedSlot: clearSelected ? null : (selectedSlot ?? this.selectedSlot),
      activeFilter: activeFilter ?? this.activeFilter,
      isOpening: isOpening ?? this.isOpening,
    );
  }

  @override
  List<Object?> get props => [slots, selectedSlot, activeFilter, isOpening];
}

class LockerMapError extends LockerMapState {
  final String message;
  const LockerMapError(this.message);
  @override
  List<Object?> get props => [message];
}

class LockerOpenSuccess extends LockerMapState {
  final String lockerCode;
  const LockerOpenSuccess(this.lockerCode);
  @override
  List<Object?> get props => [lockerCode];
}
