import '../../domain/entities/locker_size.dart';
import '../../domain/entities/send_receive_order.dart';
import '../../domain/entities/storage_duration.dart';

class SendReceiveState {
  final bool isLoading;
  final List<LockerSize> lockerSizes;
  final List<StorageDuration> storageDurations;
  final String? selectedSizeId;
  final String? selectedDurationId;
  final SendReceiveOrder? currentOrder;
  final String? errorMessage;

  const SendReceiveState({
    required this.isLoading,
    required this.lockerSizes,
    required this.storageDurations,
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
    String? selectedSizeId,
    String? selectedDurationId,
    SendReceiveOrder? currentOrder,
    String? errorMessage,
    bool clearSelectedSize = false,
    bool clearSelectedDuration = false,
  }) {
    return SendReceiveState(
      isLoading: isLoading ?? this.isLoading,
      lockerSizes: lockerSizes ?? this.lockerSizes,
      storageDurations: storageDurations ?? this.storageDurations,
      selectedSizeId:
          clearSelectedSize ? null : (selectedSizeId ?? this.selectedSizeId),
      selectedDurationId: clearSelectedDuration
          ? null
          : (selectedDurationId ?? this.selectedDurationId),
      currentOrder: currentOrder ?? this.currentOrder,
      errorMessage: errorMessage ?? this.errorMessage,
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
      return storageDurations
          .firstWhere((duration) => duration.id == selectedDurationId);
    } catch (e) {
      return null;
    }
  }

  bool get canProceed => selectedSizeId != null && selectedDurationId != null;
}
