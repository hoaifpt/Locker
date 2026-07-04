import 'package:dio/dio.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/sign_up_request.dart'
    show SignUpRequest, SignUpResponse;
import '../domain/repositories/i_sign_up_repository.dart';
import 'models/sign_up_model.dart';

class SignUpRepository implements ISignUpRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      final response = await _apiClient.client.post(
        '/auth/register',
        data: SignUpRequestModel(
          username: request.username,
          fullName: request.fullName,
          email: request.email,
          password: request.password,
          phoneNumber: request.phoneNumber,

        ).toJson(),
      );

      if (response.statusCode == 200) {
        return SignUpResponseModel(
          userId: '',
          email: request.email,
          fullName: request.fullName,
          token: '',
        );
      }

      throw NetworkException('Đăng ký thất bại. Vui lòng thử lại sau.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw AppException('Email đã tồn tại. Vui lòng sử dụng email khác.');
      }
      throw NetworkException(e.message ?? 'Lỗi mạng khi đăng ký');
    } catch (e) {
      throw AppException('Đăng ký thất bại: $e');
    }
  }
}
