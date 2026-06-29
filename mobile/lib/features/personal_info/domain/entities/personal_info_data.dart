class PersonalInfoData {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String address;
  final String? birthday;
  final String membershipTier;
  final String avatarUrl;

  const PersonalInfoData({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    this.birthday,
    required this.membershipTier,
    required this.avatarUrl,
  });
}
