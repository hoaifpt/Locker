import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/injection.dart';
import '../../data/wallet_repository.dart';
import '../../domain/services/payment_realtime_service.dart';
import '../../domain/usecases/get_wallet_overview_usecase.dart';
import '../controllers/wallet_cubit.dart';
import '../controllers/wallet_state.dart';
import '../widgets/index.dart';
import '../../widgets/wallet_balance_card_v2.dart';
import '../../widgets/wallet_transactions_section.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repo = WalletRepository();
        return WalletCubit(
          getWalletOverview: GetWalletOverviewUseCase(repository: repo),
          walletRepository: repo,
          realtimeService: getIt<IPaymentRealtimeService>(),
        )..load()..restorePending();
      },
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatefulWidget {
  const _WalletView();

  @override
  State<_WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<_WalletView> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        if (state.isLoading && state.overview == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7F7F8),
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFF97316)),
              ),
            ),
          );
        }

        if (state.errorMessage != null && state.overview == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F8),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFF97316),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF52443E),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<WalletCubit>().load(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final overview = state.overview!;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F8),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 128),
                  child: Column(
                    children: [
                      WalletHeader(
                        onBack: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context)
                                .pushNamedAndRemoveUntil('/home', (_) => false);
                          }
                        },
                        onMore: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header eyebrow
                            const Padding(
                              padding: EdgeInsets.fromLTRB(8, 8, 8, 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 13,
                                    color: Color(0xFFFB923C),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'VÍ ĐIỆN TỬ',
                                    style: TextStyle(
                                      color: Color(0xFFFB923C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            WalletBalanceCardV2(
                              balance: overview.balance,
                              onTopUp: () {
                                final cubit = context.read<WalletCubit>();
                                Navigator.pushNamed(
                                  context,
                                  '/top-up',
                                  arguments: cubit,
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            WalletTransactionsSection(
                              transactions: overview.transactions,
                              statusFilter: _statusFilter,
                              onStatusFilterChanged: (v) =>
                                  setState(() => _statusFilter = v),
                              onViewAll: () {
                                final cubit = context.read<WalletCubit>();
                                Navigator.pushNamed(
                                  context,
                                  '/wallet/transactions',
                                  arguments: cubit,
                                );
                              },
                              onRefresh: () async {
                                await context.read<WalletCubit>().load();
                              },
                              isLoading: state.isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: WalletBottomNavBar(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
