import '../../domain/entities/reservation_result.dart';

class ReservationResultModel extends ReservationResult {
  const ReservationResultModel({
    required super.orderId,
    required super.status,
    required super.totalAmount,
    required super.checkInTime,
    required super.checkOutTime,
    required super.expirationTime,
    required super.message,
  });

  factory ReservationResultModel.fromJson(Map<String, dynamic> json) {
    return ReservationResultModel(
      orderId: json['orderId'] as String,
      status: (json['status'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: DateTime.parse(json['checkOutTime'] as String),
      expirationTime: DateTime.parse(json['expirationTime'] as String),
      message: json['message'] as String,
    );
  }
}
