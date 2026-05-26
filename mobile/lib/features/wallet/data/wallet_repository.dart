import '../domain/entities/wallet_overview.dart';
import '../domain/entities/wallet_transaction.dart';
import '../domain/repositories/i_wallet_repository.dart';
import 'models/wallet_overview_model.dart';
import 'models/wallet_transaction_model.dart';

class WalletRepository implements IWalletRepository {
  @override
  Future<WalletOverview> getWalletOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final overview = WalletOverviewModel(
      balance: 2450000,
      monthlyChange: -120000,
      points: 1250,
      transactions: const [
        WalletTransactionModel(
          id: 'txn-001',
          title: 'Thanh toán tủ đồ EB-102',
          subtitle: '20/10/2023 • 14:30',
          amount: -35000,
          timeLabel: 'HOÀN TẤT',
          isIncome: false,
        ),
        WalletTransactionModel(
          id: 'txn-002',
          title: 'Nạp tiền từ VPBank',
          subtitle: '19/10/2023 • 09:15',
          amount: 500000,
          timeLabel: 'HOÀN TẤT',
          isIncome: true,
        ),
        WalletTransactionModel(
          id: 'txn-003',
          title: 'Thuê ngăn tủ L (48h)',
          subtitle: '18/10/2023 • 18:05',
          amount: -85000,
          timeLabel: 'HOÀN TẤT',
          isIncome: false,
        ),
      ],
    );

    return overview;
  }
}
