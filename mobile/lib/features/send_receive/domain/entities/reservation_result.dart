import 'package:equatable/equatable.dart';

class ReservationResult extends Equatable {
  final String orderId;
  final int status;
  final double totalAmount;
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final DateTime expirationTime;
  final String message;

  const ReservationResult({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.checkInTime,
    required this.checkOutTime,
    required this.expirationTime,
    required this.message,
  });

  @override
  List<Object?> get props => [
    orderId,
    status,
    totalAmount,
    checkInTime,
    checkOutTime,
    expirationTime,
    message,
  ];
}
