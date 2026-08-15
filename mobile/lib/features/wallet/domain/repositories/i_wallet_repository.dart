import '../entities/sepay_init_response.dart';
import '../entities/wallet_overview.dart';
import '../entities/wallet_transaction.dart';

abstract class IWalletRepository {
  Future<WalletOverview> getWalletOverview();
  Future<List<WalletTransaction>> getTransactions();
  Future<double> getBalance();
  Future<void> topUp(double amount);
  Future<void> transfer(String receiverId, double amount);
  Future<SepayInitResponse> initSePayTopUp(double amount);
}
