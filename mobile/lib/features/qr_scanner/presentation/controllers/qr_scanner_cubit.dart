import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/usecases/validate_qr_code_usecase.dart';
import 'qr_scanner_state.dart';

class QrScannerCubit extends Cubit<QrScannerState> {
  final ValidateQrCodeUsecase _validateQrCode;

  // Phòng chống quét trùng lặp trong khi đang xử lý
  bool _isProcessing = false;

  QrScannerCubit({
    required ValidateQrCodeUsecase validateQrCode,
  })  : _validateQrCode = validateQrCode,
        super(const QrScannerInitial());

  void startScanning() {
    _isProcessing = false;
    emit(const QrScannerScanning());
  }

  /// Gọi khi camera nhận diện được QR code
  Future<void> onQrDetected(String rawValue) async {
    if (_isProcessing) return;
    _isProcessing = true;
    emit(QrScannerProcessing(rawValue));
    try {
      final result = await _validateQrCode(rawValue);
      emit(QrScannerSuccess(result));
    } on AppException catch (e) {
      emit(QrScannerError(e.message));
    } catch (e) {
      emit(const QrScannerError('Mã QR không hợp lệ'));
    }
  }

  /// Reset để quét lại sau khi lỗi
  void retryScanning() {
    _isProcessing = false;
    emit(const QrScannerScanning());
  }

  /// Validate mã nhập thủ công (dùng cùng usecase)
  Future<void> onManualCodeEntered(String code) async {
    if (code.trim().isEmpty) return;
    await onQrDetected(code.trim());
  }
}
