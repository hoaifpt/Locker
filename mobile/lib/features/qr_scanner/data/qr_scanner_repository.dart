import '../../../core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/scan_result.dart';
import '../domain/repositories/i_qr_scanner_repository.dart';
import 'models/scan_result_model.dart';

class QrScannerRepository implements IQrScannerRepository {
  final ApiClient _apiClient = ApiClient();

  /// POST /api/lockers/qr-scan — validate QR code và trả về thông tin tủ
  @override
  Future<ScanResult> validateQrCode(String qrCode) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.lockersQrScan,
        data: {'qrCode': qrCode},
      );
      return ScanResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Assuming 404 or 400 for invalid QR codes
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        throw ValidationException('Mã QR không hợp lệ hoặc đã hết hạn.');
      }
      throw NetworkException('Lỗi khi quét mã QR: ${e.message}');
    } catch (e) {
      throw AppException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  /// GET /api/lockers/scan-history — lịch sử quét gần đây
  @override
  Future<List<ScanResult>> getScanHistory() async {
    try {
      final response =
          await _apiClient.client.get(ApiEndpoints.lockersScanHistory);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => ScanResultModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException('Lỗi khi tải lịch sử quét: ${e.message}');
    } catch (e) {
      throw AppException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }
}
