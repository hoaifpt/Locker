import 'package:equatable/equatable.dart';

import '../../domain/entities/locker_detail.dart';

abstract class LockerDetailState extends Equatable {
  const LockerDetailState();
  @override
  List<Object?> get props => [];
}

class LockerDetailInitial extends LockerDetailState {
  const LockerDetailInitial();
}

class LockerDetailLoading extends LockerDetailState {
  const LockerDetailLoading();
}

class LockerDetailLoaded extends LockerDetailState {
  final LockerDetail detail;
  final bool isOpening;
  final bool isUpdating;

  const LockerDetailLoaded({
    required this.detail,
    this.isOpening = false,
    this.isUpdating = false,
  });

  LockerDetailLoaded copyWith({
    LockerDetail? detail,
    bool? isOpening,
    bool? isUpdating,
  }) {
    return LockerDetailLoaded(
      detail: detail ?? this.detail,
      isOpening: isOpening ?? this.isOpening,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [detail, isOpening, isUpdating];
}

class LockerDetailError extends LockerDetailState {
  final String message;
  const LockerDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class LockerDetailOpenSuccess extends LockerDetailState {
  final String lockerCode;
  const LockerDetailOpenSuccess(this.lockerCode);
  @override
  List<Object?> get props => [lockerCode];
}
