import '../../domain/entities/wallet_overview.dart';
import 'wallet_transaction_model.dart';

class WalletOverviewModel extends WalletOverview {
  const WalletOverviewModel({
    required super.balance,
    required super.monthlyChange,
    required super.points,
    required super.transactions,
  });

  factory WalletOverviewModel.fromJson(Map<String, dynamic> json) {
    final transactionsJson = (json['transactions'] as List<dynamic>? ?? []);

    return WalletOverviewModel(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      monthlyChange: (json['monthlyChange'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      transactions: transactionsJson
          .map((item) =>
              WalletTransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
