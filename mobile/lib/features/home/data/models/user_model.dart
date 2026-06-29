import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    super.emailConfirmed,
    super.avatarUrl,
  });

  /// Creates a [UserModel] from a JSON object.
  ///
  /// Note: You may need to adjust the keys ('id', 'fullName', 'avatarUrl')
  /// to match the actual response from your API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      emailConfirmed: json['emailConfirmed'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
