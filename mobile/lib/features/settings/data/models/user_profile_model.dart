import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    super.loyaltyPoints,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      name: json['fullName'] as String? ?? json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
    );
  }

  /// Fallback khi API không trả về profile
  factory UserProfileModel.empty() => const UserProfileModel(
        id: '',
        name: 'Người dùng',
        email: '',
      );
}
