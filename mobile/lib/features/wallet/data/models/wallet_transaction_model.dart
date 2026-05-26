import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.amount,
    required super.timeLabel,
    required super.isIncome,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      timeLabel: json['timeLabel']?.toString() ?? '',
      isIncome: json['isIncome'] as bool? ?? false,
    );
  }
}
