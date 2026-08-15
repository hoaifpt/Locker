import '../entities/payment_status.dart';
import '../entities/sepay_cancel_response.dart';
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

  /// Polls the current status of a payment. Used as fallback when the
  /// realtime channel isn't available.
  Future<PaymentStatusResponse> checkPaymentStatus(String paymentId);

  /// Cancels a pending SePay top-up. Returns the backend response which
  /// includes `success` flag and `newStatus` (string).
  Future<SepayCancelResponse> cancelSepayTopUp(String paymentId);
}
