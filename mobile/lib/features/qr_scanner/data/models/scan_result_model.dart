import '../../domain/entities/scan_result.dart';

/// DTO — ánh xạ JSON từ API xuống domain entity ScanResult
class ScanResultModel extends ScanResult {
  const ScanResultModel({
    required super.id,
    required super.qrCode,
    required super.scannedAt,
    required super.isValid,
    super.lockerId,
    super.lockerCode,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
      lockerId: json['lockerId']?.toString(),
      lockerCode: json['lockerCode']?.toString(),
      scannedAt: DateTime.tryParse(json['scannedAt']?.toString() ?? '') ??
          DateTime.now(),
      isValid: json['isValid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'qrCode': qrCode,
        'lockerId': lockerId,
        'lockerCode': lockerCode,
        'scannedAt': scannedAt.toIso8601String(),
        'isValid': isValid,
      };
}
