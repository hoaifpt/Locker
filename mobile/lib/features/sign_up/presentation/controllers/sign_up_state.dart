import '../../domain/entities/sign_up_request.dart' show SignUpResponse;

class SignUpState {
  final String fullName;
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final SignUpResponse? response;

  SignUpState({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
    this.response,
  });

  SignUpState copyWith({
    String? fullName,
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    SignUpResponse? response,
  }) {
    return SignUpState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      response: response ?? this.response,
    );
  }
}
