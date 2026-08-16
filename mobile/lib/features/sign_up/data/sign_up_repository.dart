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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SignUpResponseModel(
          userId: '',
          email: request.email,
          fullName: request.fullName,
          token: '',
        );
      }

      throw NetworkException('Đăng ký thất bại. Vui lòng thử lại sau.');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Convert DioException thành domain exception. Đặc biệt với 400, khi
  /// backend ASP.NET trả ProblemDetails với `errors: {Field: [...]}` hoặc
  /// `message` thường (`Username 'x' is invalid...`), ta unwrap và
  /// đưa về ValidationException / AppException tương ứng để
  /// FriendlyError render đúng.
  Exception _mapDioError(DioException e) {
    final status = e.response?.statusCode ?? 0;
    final data = e.response?.data;

    if (data is Map) {
      // 1. ProblemDetails.errors — model validation (400) thường đi vào đây
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final fieldErrors = <String, List<String>>{};
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List) {
            fieldErrors[entry.key.toString()] =
                value.map((v) => v.toString()).toList();
          } else if (value is String) {
            fieldErrors[entry.key.toString()] = [value];
          }
        }
        // Lấy message đầu tiên làm message chính cho SnackBar / Dialog.
        final firstField = fieldErrors.entries.first;
        final firstMsg = firstField.value.isNotEmpty
            ? firstField.value.first
            : firstField.key;
        return ValidationException(
          firstMsg,
          fieldErrors: fieldErrors,
          code: status.toString(),
        );
      }

      // 2. Identity / Conflict message — backend thường trả `{message: "..."}`
      final raw = data['message'] ?? data['Message'];
      if (raw is String && raw.trim().isNotEmpty) {
        // 409: tài khoản/email/sđt đã tồn tại — surface nguyên xi
        if (status == 409) return AppException(raw);
        return AppException(raw);
      }
    }

    if (status == 409) {
      return AppException(
        'Tài khoản, email hoặc số điện thoại đã tồn tại.',
      );
    }

    // Network / timeout — fallback message chung
    return NetworkException(e.message ?? 'Lỗi mạng khi đăng ký');
  }
}