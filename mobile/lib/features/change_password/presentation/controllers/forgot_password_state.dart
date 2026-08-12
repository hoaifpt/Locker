import 'package:equatable/equatable.dart';

class ForgotPasswordState extends Equatable {
  final bool isLoading;
  final bool isOtpSent;
  final bool isSuccess;
  final String? errorMessage;
  final String? email;

  const ForgotPasswordState({
    this.isLoading = false,
    this.isOtpSent = false,
    this.isSuccess = false,
    this.errorMessage,
    this.email,
  });

  factory ForgotPasswordState.initial() => const ForgotPasswordState();

  ForgotPasswordState copyWith({
    bool? isLoading,
    bool? isOtpSent,
    bool? isSuccess,
    String? errorMessage,
    String? email,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [isLoading, isOtpSent, isSuccess, errorMessage, email];
}
