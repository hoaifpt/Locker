import '../entities/scan_result.dart';
import '../repositories/i_qr_scanner_repository.dart';

class ValidateQrCodeUsecase {
  final IQrScannerRepository _repo;
  const ValidateQrCodeUsecase(this._repo);

  Future<ScanResult> call(String qrCode) => _repo.validateQrCode(qrCode);
}
