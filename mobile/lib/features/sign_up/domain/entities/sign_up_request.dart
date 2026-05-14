class SignUpRequest {
  final String fullName;
  final String email;
  final String password;

  SignUpRequest({
    required this.fullName,
    required this.email,
    required this.password,
  });
}

class SignUpResponse {
  final String userId;
  final String email;
  final String fullName;
  final String token;

  SignUpResponse({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.token,
  });
}
