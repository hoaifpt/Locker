import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/entities/wallet_overview.dart';
import '../domain/entities/wallet_transaction.dart';
import '../domain/repositories/i_wallet_repository.dart';
import 'models/wallet_overview_model.dart';
import 'models/wallet_transaction_model.dart';

class WalletRepository implements IWalletRepository {
  final ApiClient _apiClient = ApiClient();

  String _url(String endpoint) => '${AppConstants.apiBaseUrl}$endpoint';

  @override
  Future<WalletOverview> getWalletOverview() async {
    try {
      final response = await _apiClient.client.get(_url(ApiEndpoints.walletOverview));
      if (response.statusCode == 200) {
        return WalletOverviewModel.fromJson(response.data);
      }
      throw NetworkException('Failed to load wallet overview');
    } on DioException catch (e) {
      throw NetworkException('Error loading wallet: ${e.message}');
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    try {
      final response = await _apiClient.client.get(_url(ApiEndpoints.walletTransactions));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => WalletTransactionModel.fromJson(json)).toList();
      }
      throw NetworkException('Failed to load transactions');
    } on DioException catch (e) {
      throw NetworkException('Error loading transactions: ${e.message}');
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<double> getBalance() async {
    try {
      final response = await _apiClient.client.get(_url(ApiEndpoints.walletBalance));
      if (response.statusCode == 200) {
        return (response.data['balance'] as num).toDouble();
      }
      throw NetworkException('Failed to get balance');
    } catch (e) {
      throw AppException('Error getting balance: $e');
    }
  }

  @override
  Future<void> topUp(double amount) async {
    try {
      await _apiClient.client.post(_url(ApiEndpoints.walletTopUp), data: {'amount': amount});
    } catch (e) {
      throw AppException('Top-up failed: $e');
    }
  }

  @override
  Future<void> transfer(String receiverId, double amount) async {
    try {
      await _apiClient.client.post(
        _url(AppConstants.apiBaseUrl + ApiEndpoints.walletTransfer),
        data: {'receiverId': receiverId, 'amount': amount},
      );
    } catch (e) {
      throw AppException('Transfer failed: $e');
    }
  }

  @override
  Future<String> initSePayTopUp(double amount) async {
    try {
      final response = await _apiClient.client.post(
        _url(ApiEndpoints.walletTopUpSePayInit),
        data: {'amount': amount},
      );

      if (response.statusCode == 200 && response.data != null) {
        // Backend trả về trường 'checkoutUrl' hoặc 'paymentUrl'
        final String? url = response.data['checkoutUrl'] ?? response.data['paymentUrl'];

        if (url != null && url.isNotEmpty) {
          return url;
        }
        throw AppException('Hệ thống chưa tạo được liên kết thanh toán. Vui lòng thử lại.');
      }
      throw NetworkException('Lỗi kết nối thanh toán (Mã: ${response.statusCode})');
    } on DioException catch (e) {
      throw AppException('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw AppException('Không thể bắt đầu thanh toán: $e');
    }
  }
}
