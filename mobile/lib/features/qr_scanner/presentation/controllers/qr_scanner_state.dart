import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_result.dart';

abstract class QrScannerState extends Equatable {
  const QrScannerState();
  @override
  List<Object?> get props => [];
}

/// Camera chưa khởi động
class QrScannerInitial extends QrScannerState {
  const QrScannerInitial();
}

/// Camera đang hoạt động, chờ quét
class QrScannerScanning extends QrScannerState {
  const QrScannerScanning();
}

/// Đã nhận được QR, đang gửi lên API validate
class QrScannerProcessing extends QrScannerState {
  final String rawValue;
  const QrScannerProcessing(this.rawValue);
  @override
  List<Object?> get props => [rawValue];
}

/// QR hợp lệ — navigate đến locker-detail
class QrScannerSuccess extends QrScannerState {
  final ScanResult result;
  const QrScannerSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

/// QR không hợp lệ hoặc lỗi mạng
class QrScannerError extends QrScannerState {
  final String message;
  const QrScannerError(this.message);
  @override
  List<Object?> get props => [message];
}
