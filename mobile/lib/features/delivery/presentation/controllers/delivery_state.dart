import '../../domain/entities/delivery_package_size.dart';

class DeliveryState {
  final bool isLoading;
  final List<DeliveryPackageSize> packageSizes;
  final String selectedSizeId;
  final String sendCode;
  final String receiveCode;
  final String? feedbackMessage;

  const DeliveryState({
    required this.isLoading,
    required this.packageSizes,
    required this.selectedSizeId,
    required this.sendCode,
    required this.receiveCode,
    this.feedbackMessage,
  });

  factory DeliveryState.initial() {
    return const DeliveryState(
      isLoading: true,
      packageSizes: [],
      selectedSizeId: '',
      sendCode: '',
      receiveCode: '',
    );
  }

  DeliveryState copyWith({
    bool? isLoading,
    List<DeliveryPackageSize>? packageSizes,
    String? selectedSizeId,
    String? sendCode,
    String? receiveCode,
    String? feedbackMessage,
    bool clearMessage = false,
  }) {
    return DeliveryState(
      isLoading: isLoading ?? this.isLoading,
      packageSizes: packageSizes ?? this.packageSizes,
      selectedSizeId: selectedSizeId ?? this.selectedSizeId,
      sendCode: sendCode ?? this.sendCode,
      receiveCode: receiveCode ?? this.receiveCode,
      feedbackMessage:
          clearMessage ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }
}
