import 'package:equatable/equatable.dart';

class LockerSlot extends Equatable {
  final int index;
  final int status; // Assuming 0 = available
  final String size;

  const LockerSlot({
    required this.index,
    required this.status,
    required this.size,
  });

  bool get isAvailable => status == 0;

  @override
  List<Object?> get props => [index, status, size];
}
