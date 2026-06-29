import 'package:equatable/equatable.dart';

class ChangePasswordState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ChangePasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  factory ChangePasswordState.initial() => const ChangePasswordState();

  ChangePasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage, // Nếu truyền null thì xóa error
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMessage];
}
