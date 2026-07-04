import 'package:equatable/equatable.dart';

import '../../../locker/domain/entities/locker.dart';
import '../../domain/entities/locker_size.dart';
import '../../domain/entities/send_receive_order.dart';
import '../../domain/entities/storage_duration.dart';

class SendReceiveState extends Equatable {
  final bool isLoading;
  final List<LockerSize> lockerSizes;
  final List<StorageDuration> storageDurations;
  final List<Locker> lockers;
  final String? selectedLockerId;
  final int? selectedSlotIndex;
  final String? selectedSizeId;
  final String? selectedDurationId;
  final SendReceiveOrder? currentOrder;
  final String? errorMessage;

  const SendReceiveState({
    required this.isLoading,
    required this.lockerSizes,
    required this.storageDurations,
    required this.lockers,
    this.selectedLockerId,
    this.selectedSlotIndex,
    this.selectedSizeId,
    this.selectedDurationId,
    this.currentOrder,
    this.errorMessage,
  });

  factory SendReceiveState.initial() {
    return const SendReceiveState(
      isLoading: true,
      lockerSizes: [],
      storageDurations: [],
      lockers: [],
      selectedLockerId: null,
      selectedSlotIndex: null,
      selectedSizeId: null,
      selectedDurationId: null,
      currentOrder: null,
      errorMessage: null,
    );
  }

  SendReceiveState copyWith({
    bool? isLoading,
    List<LockerSize>? lockerSizes,
    List<StorageDuration>? storageDurations,
    List<Locker>? lockers,
    String? selectedLockerId,
    int? selectedSlotIndex,
    String? selectedSizeId,
    String? selectedDurationId,
    SendReceiveOrder? currentOrder,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool clearSelectedSize = false,
    bool clearSelectedDuration = false,
    bool clearSelectedLocker = false,
    bool clearSelectedSlot = false,
  }) {
    return SendReceiveState(
      isLoading: isLoading ?? this.isLoading,
      lockerSizes: lockerSizes ?? this.lockerSizes,
      storageDurations: storageDurations ?? this.storageDurations,
      lockers: lockers ?? this.lockers,
      selectedSizeId: clearSelectedSize
          ? null
          : (selectedSizeId ?? this.selectedSizeId),
      selectedLockerId: clearSelectedLocker
          ? null
          : (selectedLockerId ?? this.selectedLockerId),
      selectedSlotIndex: clearSelectedSlot
          ? null
          : (selectedSlotIndex ?? this.selectedSlotIndex),
      selectedDurationId: clearSelectedDuration
          ? null
          : (selectedDurationId ?? this.selectedDurationId),
      currentOrder: currentOrder ?? this.currentOrder,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  LockerSize? get selectedSize {
    if (selectedSizeId == null) return null;
    try {
      return lockerSizes.firstWhere((size) => size.id == selectedSizeId);
    } catch (e) {
      return null;
    }
  }

  StorageDuration? get selectedDuration {
    if (selectedDurationId == null) return null;
    try {
      return storageDurations.firstWhere(
        (duration) => duration.id == selectedDurationId,
      );
    } catch (e) {
      return null;
    }
  }

  Locker? get selectedLocker {
    if (selectedLockerId == null) return null;
    try {
      return lockers.firstWhere((locker) => locker.id == selectedLockerId);
    } catch (e) {
      return null;
    }
  }

  bool get canProceed =>
      selectedSizeId != null &&
      selectedDurationId != null &&
      selectedLockerId != null &&
      selectedSlotIndex != null;

  @override
  List<Object?> get props => [
    isLoading,
    lockerSizes,
    storageDurations,
    lockers,
    selectedLockerId,
    selectedSlotIndex,
    selectedSizeId,
    selectedDurationId,
    currentOrder,
    errorMessage,
  ];
}
