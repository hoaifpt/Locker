import 'package:equatable/equatable.dart';

class VerifyEmailState extends Equatable {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  const VerifyEmailState({
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  VerifyEmailState copyWith({
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
    bool? clearMessages,
  }) {
    return VerifyEmailState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: (clearMessages ?? false) ? null : successMessage,
      errorMessage: (clearMessages ?? false) ? null : errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, successMessage, errorMessage];
}
