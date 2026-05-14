import '../../domain/entities/sign_up_request.dart';

class SignUpRequestModel extends SignUpRequest {
  SignUpRequestModel({
    required super.fullName,
    required super.email,
    required super.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
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
