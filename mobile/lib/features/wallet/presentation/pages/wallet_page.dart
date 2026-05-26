import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/wallet_repository.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/usecases/get_wallet_overview_usecase.dart';
import '../controllers/wallet_cubit.dart';
import '../controllers/wallet_state.dart';
import '../widgets/index.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletCubit(
        getWalletOverview: GetWalletOverviewUseCase(
          repository: WalletRepository(),
        ),
      )..load(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        if (state.isLoading && state.overview == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9F9F9),
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFD8D64)),
              ),
            ),
          );
        }

        if (state.errorMessage != null && state.overview == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Color(0xFFFD8D64)),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF52443E),
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<WalletCubit>().load(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFD8D64),
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
          backgroundColor: const Color(0xFFF9F9F9),
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
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          }
                        },
                        onMore: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WalletBalanceCard(
                              balance: overview.balance,
                              monthlyChange: overview.monthlyChange,
                              points: overview.points,
                              onTopUp: () {},
                              onWithdraw: () {},
                            ),
                            const SizedBox(height: 32),
                            _SectionHeader(
                              title: 'Giao dịch gần đây',
                              actionLabel: 'Xem tất cả',
                              onActionTap: () {},
                            ),
                            const SizedBox(height: 24),
                            _TransactionsList(
                              transactions: overview.transactions,
                            ),
                            const SizedBox(height: 24),
                            const WalletPromoBanner(),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1C1C),
            fontSize: 18,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF87503C),
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final List<WalletTransaction> transactions;

  const _TransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < transactions.length; i++) ...[
          WalletTransactionItem(transaction: transactions[i]),
          if (i != transactions.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Opacity(
                opacity: 0.5,
                child:
                    Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              ),
            ),
        ],
      ],
    );
  }
}
