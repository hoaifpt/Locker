import '../../domain/entities/sign_up_request.dart' show SignUpResponse;

class SignUpState {
  final String username;
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;
  final bool isLoading;
  final String? errorMessage;
  final SignUpResponse? response;

  SignUpState({
    this.username = '',
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.phoneNumber = '',
    this.isLoading = false,
    this.errorMessage,
    this.response,
  });

  SignUpState copyWith({
    String? username,
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    bool? isLoading,
    String? errorMessage,
    SignUpResponse? response,
  }) {
    return SignUpState(
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      response: response ?? this.response,
    );
  }
}
