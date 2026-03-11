class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int loyaltyPoints;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.loyaltyPoints = 0,
  });
}
