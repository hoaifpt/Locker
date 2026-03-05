import 'package:dio/dio.dart';

import '../exceptions/app_exception.dart';
import '../utils/logger.dart';
import 'api_client.dart';

/// Lớp wrapper cho Dio, gom xử lý lỗi và log chung
class NetworkService {
  final Dio _dio;

  NetworkService({Dio? dio}) : _dio = dio ?? ApiClient().client;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _wrap(() =>
        _dio.get<T>(path, queryParameters: queryParameters, options: options));
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _wrap(() => _dio.post<T>(path,
        data: data, queryParameters: queryParameters, options: options));
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _wrap(() => _dio.put<T>(path,
        data: data, queryParameters: queryParameters, options: options));
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _wrap(() => _dio.delete<T>(path,
        data: data, queryParameters: queryParameters, options: options));
  }

  Future<Response<T>> _wrap<T>(Future<Response<T>> Function() call) async {
    try {
      final res = await call();
      logInfo(
          '[HTTP ${res.statusCode}] ${res.requestOptions.method} ${res.requestOptions.uri}');
      return res;
    } on DioException catch (e) {
      logError('HTTP error: ${e.message}');
      throw _mapDioError(e);
    } catch (e) {
      logError('Unexpected error: $e');
      throw AppException('Lỗi không xác định');
    }
  }

  AppException _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401) {
      return UnauthorizedException('Phiên đăng nhập hết hạn hoặc không hợp lệ');
    }
    if (status == 408) return TimeoutAppException('Hết thời gian kết nối');
    if (status == 400 && e.response?.data is Map<String, dynamic>) {
      return ValidationException('Dữ liệu không hợp lệ',
          fieldErrors: _extractFieldErrors(e.response!.data));
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutAppException('Hết thời gian kết nối');
    }
    return NetworkException(e.message ?? 'Lỗi mạng');
  }

  Map<String, List<String>>? _extractFieldErrors(Map<String, dynamic> data) {
    final errors = <String, List<String>>{};
    data.forEach((key, value) {
      if (value is List) {
        errors[key] = value.map((e) => e.toString()).toList();
      } else if (value != null) {
        errors[key] = [value.toString()];
      }
    });
    return errors.isEmpty ? null : errors;
  }
}
