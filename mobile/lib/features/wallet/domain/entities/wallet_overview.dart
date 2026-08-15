import 'wallet_transaction.dart';

class WalletOverview {
  final int balance;
  final int monthlyChange;
  final int points;
  final List<WalletTransaction> transactions;

  const WalletOverview({
    required this.balance,
    required this.monthlyChange,
    required this.points,
    required this.transactions,
  });
}
