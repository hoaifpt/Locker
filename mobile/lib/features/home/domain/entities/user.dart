import 'package:equatable/equatable.dart';

/// {@template user}
/// Pure domain entity for a user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.id,
    required this.fullName,
    this.emailConfirmed = false,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final bool emailConfirmed;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, fullName, emailConfirmed, avatarUrl];
}
