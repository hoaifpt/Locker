import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/wallet_cubit.dart';
import '../controllers/wallet_state.dart';
import '../../widgets/wallet_transactions_section.dart';

/// Full transaction history page. Reached from the "Xem tất cả" CTA on
/// `WalletPage`. Mirrors the in-page history block in
/// `web/src/features/wallet/pages/WalletPage.tsx` (lines 1173-1238) but
/// with a dedicated page chrome so mobile users get the same affordance
/// without scrolling.
class WalletTransactionsPage extends StatefulWidget {
  final WalletCubit cubit;

  const WalletTransactionsPage({super.key, required this.cubit});

  @override
  State<WalletTransactionsPage> createState() => _WalletTransactionsPageState();
}

class _WalletTransactionsPageState extends State<WalletTransactionsPage> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Make sure the latest data is on screen — the parent may have stale
    // state if the user kept the app in background for a while.
    widget.cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F8),
          elevation: 0,
          foregroundColor: const Color(0xFF0F172A),
          title: const Text(
            'Lịch sử giao dịch',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<WalletCubit, WalletState>(
            builder: (context, state) {
              final transactions = state.overview?.transactions ?? [];
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: WalletTransactionsSection(
                  transactions: transactions,
                  statusFilter: _statusFilter,
                  onStatusFilterChanged: (v) =>
                      setState(() => _statusFilter = v),
                  onViewAll: () {},
                  onRefresh: () async {
                    await context.read<WalletCubit>().load();
                  },
                  isLoading: state.isLoading,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
