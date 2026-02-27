import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({required super.id, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'], email: json['email']);

  Map<String, dynamic> toJson() => {'id': id, 'email': email};
}
