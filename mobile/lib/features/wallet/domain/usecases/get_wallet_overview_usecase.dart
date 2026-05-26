import '../entities/wallet_overview.dart';
import '../repositories/i_wallet_repository.dart';

class GetWalletOverviewUseCase {
  final IWalletRepository repository;

  GetWalletOverviewUseCase({required this.repository});

  Future<WalletOverview> call() {
    return repository.getWalletOverview();
  }
}
