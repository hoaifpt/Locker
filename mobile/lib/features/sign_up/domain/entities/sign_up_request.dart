class SignUpRequest {
  final String username;
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;

  SignUpRequest({
    required this.username,
    required this.fullName,
    required this.email,
    required this.password,
    required this.phoneNumber,
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
