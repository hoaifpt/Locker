import '../../domain/entities/sign_up_request.dart';

class SignUpRequestModel extends SignUpRequest {
  SignUpRequestModel({
    required super.username,
    required super.fullName,
    required super.email,
    required super.password,
    required super.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'fullName': fullName,
      'password': password,
      'phoneNumber': phoneNumber,
    };
  }
}

class SignUpResponseModel extends SignUpResponse {
  SignUpResponseModel({
    required super.userId,
    required super.email,
    required super.fullName,
    required super.token,
  });

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      token: json['token'] as String,
    );
  }
}
