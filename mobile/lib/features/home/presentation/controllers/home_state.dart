import 'package:equatable/equatable.dart';

import '../../../locker/domain/entities/locker.dart';
import '../../domain/entities/active_locker.dart';
import '../../domain/entities/user.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final User user;
  final List<ActiveLocker> activeLockers;
  final List<Locker> nearbyLockers;

  const HomeLoaded({
    required this.user,
    required this.activeLockers,
    required this.nearbyLockers,
  });

  @override
  List<Object?> get props => [user, activeLockers, nearbyLockers];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
