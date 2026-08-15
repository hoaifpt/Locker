import '../../domain/entities/wallet_overview.dart';

class WalletState {
  final bool isLoading;
  final WalletOverview? overview;
  final String? errorMessage;

  const WalletState({
    required this.isLoading,
    this.overview,
    this.errorMessage,
  });

  factory WalletState.initial() => const WalletState(isLoading: true);

  WalletState copyWith({
    bool? isLoading,
    WalletOverview? overview,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      overview: overview ?? this.overview,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
