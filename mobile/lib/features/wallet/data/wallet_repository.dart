import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/exceptions/app_exception.dart';
import '../domain/entities/wallet_overview.dart';
import '../domain/entities/wallet_transaction.dart';
import '../domain/repositories/i_wallet_repository.dart';
import 'models/wallet_overview_model.dart';
import 'models/wallet_transaction_model.dart';

class WalletRepository implements IWalletRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<WalletOverview> getWalletOverview() async {
    try {
      final response = await _apiClient.client.get('/wallet/overview');

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
      final response = await _apiClient.client.get('/wallet/transactions');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => WalletTransactionModel.fromJson(json))
            .toList();
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
      final response = await _apiClient.client.get('/wallet/balance');
      if (response.statusCode == 200) {
        return (response.data as num).toDouble();
      }
      throw NetworkException('Failed to get balance');
    } catch (e) {
      throw AppException('Error getting balance: $e');
    }
  }

  @override
  Future<void> topUp(double amount) async {
    try {
      await _apiClient.client.post('/wallet/top-up', data: {'amount': amount});
    } catch (e) {
      throw AppException('Top-up failed: $e');
    }
  }

  @override
  Future<void> transfer(String receiverId, double amount) async {
    try {
      await _apiClient.client.post(
        '/wallet/transfer',
        data: {'receiverId': receiverId, 'amount': amount},
      );
    } catch (e) {
      throw AppException('Transfer failed: $e');
    }
  }

  @override
  Future<String> initVnPayTopUp(double amount) async {
    try {
      final response = await _apiClient.client.post(
        '/wallet/top-up/vnpay/init',
        data: {'amount': amount},
      );
      if (response.statusCode == 200) {
        return response.data['vnPayUrl'];
      }
      throw NetworkException('VNPay initialization failed');
    } catch (e) {
      throw AppException('VNPay error: $e');
    }
  }
}
