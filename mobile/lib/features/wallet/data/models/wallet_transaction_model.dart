import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.amount,
    super.type,
    super.status,
    super.description,
    super.createdAt,
    super.title,
    super.subtitle,
    super.timeLabel,
    super.isIncome,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toInt() ?? 0;
    final type = (json['type'] as num?)?.toInt() ?? 0;
    final status = (json['status'] as num?)?.toInt() ?? 1;
    final createdAt = _parseDate(json['createdAt']);

    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      amount: amount,
      type: type,
      status: status,
      description: json['description']?.toString(),
      createdAt: createdAt,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      timeLabel: json['timeLabel']?.toString() ?? '',
      isIncome: json['isIncome'] as bool? ?? (amount > 0 || type == 0),
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      return DateTime.tryParse(raw)?.toLocal();
    }
    return null;
  }
}
