class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
  });
}
