import 'wallet_transaction.dart';

class WalletOverview {
  final int balance;
  final int monthlyChange;
  final int points;
  final int recentTransactionsCount;
  final List<WalletTransaction> transactions;

  const WalletOverview({
    required this.balance,
    required this.monthlyChange,
    required this.points,
    this.recentTransactionsCount = 0,
    this.transactions = const [],
  });

  WalletOverview copyWith({
    int? balance,
    int? monthlyChange,
    int? points,
    int? recentTransactionsCount,
    List<WalletTransaction>? transactions,
  }) {
    return WalletOverview(
      balance: balance ?? this.balance,
      monthlyChange: monthlyChange ?? this.monthlyChange,
      points: points ?? this.points,
      recentTransactionsCount:
          recentTransactionsCount ?? this.recentTransactionsCount,
      transactions: transactions ?? this.transactions,
    );
  }
}
