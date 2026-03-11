import '../entities/scan_result.dart';

abstract class IQrScannerRepository {
  /// Gửi QR code lên API để validate → trả về thông tin tủ
  Future<ScanResult> validateQrCode(String qrCode);

  /// Lấy danh sách lịch sử quét gần đây
  Future<List<ScanResult>> getScanHistory();
}
