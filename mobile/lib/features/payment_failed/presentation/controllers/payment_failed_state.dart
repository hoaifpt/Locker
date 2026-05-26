import '../../domain/entities/payment_failed_info.dart';

class PaymentFailedState {
  final bool isLoading;
  final PaymentFailedInfo? info;
  final String? errorMessage;

  const PaymentFailedState({
    required this.isLoading,
    this.info,
    this.errorMessage,
  });

  factory PaymentFailedState.initial() =>
      const PaymentFailedState(isLoading: true);

  PaymentFailedState copyWith({
    bool? isLoading,
    PaymentFailedInfo? info,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentFailedState(
      isLoading: isLoading ?? this.isLoading,
      info: info ?? this.info,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
