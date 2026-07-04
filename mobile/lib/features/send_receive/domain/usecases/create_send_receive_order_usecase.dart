import 'dart:developer';
import 'package:dio/dio.dart';

import '../repositories/i_send_receive_repository.dart';

class CreateSendReceiveOrderUseCase {
  final ISendReceiveRepository repository;

  CreateSendReceiveOrderUseCase({required this.repository});

  Future<Map<String, dynamic>> call({
    required String lockerId,
    required int slotIndex,
    required String packageId,
    required String mobileNumber,
    required DateTime checkInTime,
    required int durationHours,
    String? couponCode,
    String? notes,
  }) async {
    final requestBodyForLogging = {
      'lockerId': lockerId,
      'slotIndex': slotIndex,
      'packageId': packageId,
      'mobileNumber': mobileNumber,
      'checkInTime': checkInTime.toUtc().toIso8601String(),
      'durationHours': durationHours,
      'couponCode': couponCode,
      'notes': notes,
    };

    log('--- Creating Order ---');
    log('Endpoint: POST /api/orders/reserve');
    log('Request Body: $requestBodyForLogging');

    try {
      return await repository.createSendReceiveOrder(
        lockerId: lockerId,
        slotIndex: slotIndex,
        packageId: packageId,
        mobileNumber: mobileNumber,
        checkInTime: checkInTime,
        durationHours: durationHours,
        couponCode: couponCode,
        notes: notes,
      );
    } on DioException catch (e) {
      log(
        'DioException on Create Order: ${e.response?.statusCode} - ${e.response?.data}',
      );
      rethrow;
    }
  }
}
