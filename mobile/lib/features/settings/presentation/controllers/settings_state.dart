import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final UserProfile profile;
  final bool pushNotifications;
  final bool darkMode;

  const SettingsLoaded({
    required this.profile,
    required this.pushNotifications,
    required this.darkMode,
  });

  SettingsLoaded copyWith({
    UserProfile? profile,
    bool? pushNotifications,
    bool? darkMode,
  }) {
    return SettingsLoaded(
      profile: profile ?? this.profile,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  @override
  List<Object?> get props => [profile, pushNotifications, darkMode];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

class SettingsLoggedOut extends SettingsState {
  const SettingsLoggedOut();
}
