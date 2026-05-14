import '../../domain/entities/send_receive_order.dart';
import 'locker_size_model.dart';
import 'storage_duration_model.dart';

class SendReceiveOrderModel extends SendReceiveOrder {
  const SendReceiveOrderModel({
    required super.id,
    required super.lockerId,
    required super.lockerCode,
    required super.location,
    required LockerSizeModel super.size,
    required StorageDurationModel super.duration,
    required super.estimatedFee,
    required super.status,
    required super.createdAt,
  });

  factory SendReceiveOrderModel.fromJson(Map<String, dynamic> json) {
    return SendReceiveOrderModel(
      id: json['id'] as String,
      lockerId: json['lockerId'] as String,
      lockerCode: json['lockerCode'] as String,
      location: json['location'] as String,
      size: LockerSizeModel.fromJson(json['size'] as Map<String, dynamic>),
      duration: StorageDurationModel.fromJson(
        json['duration'] as Map<String, dynamic>,
      ),
      estimatedFee: json['estimatedFee'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lockerId': lockerId,
      'lockerCode': lockerCode,
      'location': location,
      'size': (size as LockerSizeModel).toJson(),
      'duration': (duration as StorageDurationModel).toJson(),
      'estimatedFee': estimatedFee,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
