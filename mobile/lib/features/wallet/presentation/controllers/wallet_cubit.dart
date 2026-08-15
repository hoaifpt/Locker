import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sepay_init_response.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../../domain/usecases/get_wallet_overview_usecase.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletOverviewUseCase _getWalletOverview;
  final IWalletRepository _walletRepository;

  WalletCubit({
    required GetWalletOverviewUseCase getWalletOverview,
    required IWalletRepository walletRepository,
  }) : _getWalletOverview = getWalletOverview,
       _walletRepository = walletRepository,
       super(WalletState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final overview = await _getWalletOverview();
      emit(state.copyWith(isLoading: false, overview: overview));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không tải được ví E-BOX: $e',
        ),
      );
    }
  }

  /// Starts a SePay top-up and returns the full backend payload
  /// (paymentId, paymentUrl, amount, sepayCode, expiresAt) so callers
  /// can poll status, show a countdown, and copy the transfer content.
  Future<SepayInitResponse?> topUp(double amount) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final response = await _walletRepository.initSePayTopUp(amount);
      emit(state.copyWith(isLoading: false));
      return response;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Khởi tạo thanh toán thất bại: $e',
        ),
      );
      return null;
    }
  }
}
