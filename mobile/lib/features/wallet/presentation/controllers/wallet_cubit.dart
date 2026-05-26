import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_wallet_overview_usecase.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletOverviewUseCase _getWalletOverview;

  WalletCubit({required GetWalletOverviewUseCase getWalletOverview})
      : _getWalletOverview = getWalletOverview,
        super(WalletState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final overview = await _getWalletOverview();
      emit(state.copyWith(isLoading: false, overview: overview));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không tải được ví E-BOX: $e',
      ));
    }
  }
}
