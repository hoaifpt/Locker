import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

/// App đang kiểm tra token đã lưu — show splash spinner.
class AuthLoading extends AuthState {}

/// Không có token hợp lệ — show LoginPage.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  /// Object gốc đã throw (DioException, AppException, ...). UI nên map
  /// qua `FriendlyError.message(error)` thay vì dùng [message] thẳng.
  final Object? error;

  /// Pre-formatted fallback message cho trường hợp UI muốn hiển thị
  /// nhanh không qua mapper. Vẫn được sanitize (đã strip
  /// "AppException: " prefix) để không leak exception class name.
  final String message;

  const AuthError(this.message, {this.error});

  @override
  List<Object?> get props => [message, error];
}