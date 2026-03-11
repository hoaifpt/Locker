import '../entities/scan_result.dart';
import '../repositories/i_qr_scanner_repository.dart';

class GetScanHistoryUsecase {
  final IQrScannerRepository _repo;
  const GetScanHistoryUsecase(this._repo);

  Future<List<ScanResult>> call() => _repo.getScanHistory();
}
