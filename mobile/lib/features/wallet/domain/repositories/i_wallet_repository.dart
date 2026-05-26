import '../entities/wallet_overview.dart';

abstract class IWalletRepository {
  Future<WalletOverview> getWalletOverview();
}
