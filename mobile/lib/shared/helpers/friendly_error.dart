import 'dart:io' show SocketException;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../core/exceptions/app_exception.dart';

/// Maps any thrown error (Dio, AppException, FormatException, raw Object)
/// into a short, user-friendly Vietnamese message. Avoid leaking
/// developer-only details like stack traces, JSON bodies, or exception
/// class names — the user only needs to know what went wrong and what
/// to try next.
class FriendlyError {
  FriendlyError._();

  static String message(Object error) {
    // 1. Domain exceptions -------------------------------------------------
    if (error is UnauthorizedException) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }
    if (error is ValidationException) {
      return _flattenValidation(error);
    }
    if (error is TimeoutAppException) {
      return 'Yêu cầu quá thời gian chờ. Vui lòng thử lại.';
    }
    if (error is NetworkException) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.';
    }
    if (error is AppException) {
      // Some repos already throw polished messages — pass them through,
      // but trim anything that looks like a raw exception prefix.
      return _sanitize(error.message);
    }

    // 2. Dio (network) -----------------------------------------------------
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Yêu cầu quá thời gian chờ. Vui lòng thử lại.';
        case DioExceptionType.connectionError:
          return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.';
        case DioExceptionType.badCertificate:
          return 'Chứng chỉ máy chủ không hợp lệ. Vui lòng liên hệ hỗ trợ.';
        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị huỷ.';
        case DioExceptionType.badResponse:
          return _mapBadResponse(error.response);
        case DioExceptionType.unknown:
        case DioExceptionType.transformTimeout:
          if (error.error is SocketException) {
            return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.';
          }
          return 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';
      }
    }

    // 3. Format / parse ----------------------------------------------------
    if (error is FormatException) {
      return 'Dữ liệu phản hồi từ máy chủ không hợp lệ. Vui lòng thử lại.';
    }

    // 4. Platform / fallback ----------------------------------------------
    if (error is PlatformException) {
      return error.message ??
          'Thiết bị chưa sẵn sàng. Vui lòng thử lại.';
    }

    return 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';
  }

  static String _flattenValidation(ValidationException e) {
    if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
      final firstField = e.fieldErrors!.entries.first;
      final firstMsg = firstField.value.isNotEmpty
          ? firstField.value.first
          : firstField.key;
      return _sanitize(firstMsg);
    }
    return _sanitize(e.message);
  }

  static String _mapBadResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final data = response?.data;

    // Try to extract `message` from the body — backend usually returns it.
    String? apiMessage;
    if (data is Map) {
      final raw = data['message'] ?? data['Message'] ?? data['error'];
      if (raw is String && raw.trim().isNotEmpty) {
        apiMessage = _sanitize(raw);
      }
    }

    if (apiMessage != null) return apiMessage;

    switch (status) {
      case 400:
        return 'Yêu cầu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
      case 401:
        return 'Tài khoản hoặc mật khẩu không đúng.';
      case 403:
        return 'Bạn không có quyền thực hiện thao tác này.';
      case 404:
        return 'Không tìm thấy dữ liệu yêu cầu.';
      case 409:
        return 'Dữ liệu đã tồn tại hoặc xung đột. Vui lòng thử lại.';
      case 422:
        return 'Thông tin chưa hợp lệ. Vui lòng kiểm tra lại.';
      case 429:
        return 'Bạn đã gửi quá nhiều yêu cầu. Vui lòng thử lại sau ít phút.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau ít phút.';
    }
    return 'Yêu cầu thất bại (mã $status). Vui lòng thử lại.';
  }

  /// Strip leading exception prefixes like "AppException: " or
  /// "NetworkException: " that would otherwise leak into the UI.
  static String _sanitize(String message) {
    var m = message.trim();
    final prefixes = [
      'AppException: ',
      'NetworkException: ',
      'ValidationException: ',
      'UnauthorizedException: ',
      'TimeoutAppException: ',
      'FormatException: ',
      'Exception: ',
    ];
    for (final p in prefixes) {
      if (m.startsWith(p)) {
        m = m.substring(p.length).trim();
      }
    }
    return m.isEmpty ? 'Đã xảy ra lỗi. Vui lòng thử lại.' : m;
  }
}