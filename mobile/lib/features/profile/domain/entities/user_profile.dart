class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final String membershipTier;
  final int loyaltyPoints;
  final String address;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.membershipTier,
    required this.loyaltyPoints,
    required this.address,
  });
}
