import '../../domain/entities/delivery_package_size.dart';
import '../../../../features/locker/domain/entities/locker.dart';

class DeliveryState {
  final bool isLoading;
  final List<DeliveryPackageSize> packageSizes;
  final List<Locker> lockers;
  final String selectedSizeId;
  final String? selectedLocation;
  final String? selectedLockerId;
  final int selectedSlotIndex;
  final String senderName;
  final String receiverPhone;
  final String receiveCode;
  final String? feedbackMessage;

  const DeliveryState({
    required this.isLoading,
    required this.packageSizes,
    required this.lockers,
    required this.selectedSizeId,
    this.selectedLocation,
    this.selectedLockerId,
    required this.selectedSlotIndex,
    required this.senderName,
    required this.receiverPhone,
    required this.receiveCode,
    this.feedbackMessage,
  });

  factory DeliveryState.initial() {
    return const DeliveryState(
      isLoading: true,
      packageSizes: [],
      lockers: [],
      selectedSizeId: '',
      selectedLocation: null,
      selectedLockerId: null,
      selectedSlotIndex: 0,
      senderName: '',
      receiverPhone: '',
      receiveCode: '',
    );
  }

  DeliveryState copyWith({
    bool? isLoading,
    List<DeliveryPackageSize>? packageSizes,
    List<Locker>? lockers,
    String? selectedSizeId,
    String? selectedLocation,
    String? selectedLockerId,
    int? selectedSlotIndex,
    String? senderName,
    String? receiverPhone,
    String? receiveCode,
    String? feedbackMessage,
    bool clearMessage = false,
  }) {
    return DeliveryState(
      isLoading: isLoading ?? this.isLoading,
      packageSizes: packageSizes ?? this.packageSizes,
      lockers: lockers ?? this.lockers,
      selectedSizeId: selectedSizeId ?? this.selectedSizeId,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedLockerId: selectedLockerId ?? this.selectedLockerId,
      selectedSlotIndex: selectedSlotIndex ?? this.selectedSlotIndex,
      senderName: senderName ?? this.senderName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      receiveCode: receiveCode ?? this.receiveCode,
      feedbackMessage: clearMessage
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
    );
  }
}
