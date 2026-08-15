import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

class NotificationPrefs extends Equatable {
  final bool sound;
  final bool vibration;
  final bool orderUpdates;
  final bool deliveryUpdates;
  final bool promotions;

  const NotificationPrefs({
    this.sound = true,
    this.vibration = true,
    this.orderUpdates = true,
    this.deliveryUpdates = true,
    this.promotions = false,
  });

  NotificationPrefs copyWith({
    bool? sound,
    bool? vibration,
    bool? orderUpdates,
    bool? deliveryUpdates,
    bool? promotions,
  }) {
    return NotificationPrefs(
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      deliveryUpdates: deliveryUpdates ?? this.deliveryUpdates,
      promotions: promotions ?? this.promotions,
    );
  }

  @override
  List<Object?> get props =>
      [sound, vibration, orderUpdates, deliveryUpdates, promotions];
}

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
  final bool darkMode;
  final NotificationPrefs notifications;

  const SettingsLoaded({
    required this.profile,
    required this.darkMode,
    required this.notifications,
  });

  SettingsLoaded copyWith({
    UserProfile? profile,
    bool? darkMode,
    NotificationPrefs? notifications,
  }) {
    return SettingsLoaded(
      profile: profile ?? this.profile,
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [profile, darkMode, notifications];
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
