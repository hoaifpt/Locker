import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/payment_failed_repository.dart';
import '../../domain/entities/payment_failed_info.dart';
import '../../domain/usecases/get_payment_failed_usecase.dart';
import '../controllers/payment_failed_cubit.dart';
import '../controllers/payment_failed_state.dart';
import '../widgets/index.dart';

class PaymentFailedPage extends StatelessWidget {
  final PaymentFailedRequest? request;

  const PaymentFailedPage({super.key, this.request});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentFailedCubit(
        getPaymentFailed: GetPaymentFailedUsecase(PaymentFailedRepository()),
      )..load(request),
      child: const _PaymentFailedView(),
    );
  }
}

class _PaymentFailedView extends StatelessWidget {
  const _PaymentFailedView();

  String _formatPrice(int value) {
    return '${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}đ';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentFailedCubit, PaymentFailedState>(
      builder: (context, state) {
        if (state.isLoading && state.info == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE63946)),
              ),
            ),
          );
        }

        if (state.errorMessage != null && state.info == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: Color(0xFFE63946)),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<PaymentFailedCubit>().load(null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE63946),
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

        final info = state.info!;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 136),
                  child: Column(
                    children: [
                      PaymentFailedHeader(
                        onBack: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/payment',
                              (route) => false,
                            );
                          }
                        },
                        onMore: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                        child: Column(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFE5E7),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x33E63946),
                                    blurRadius: 24,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 52,
                                color: Color(0xFFE63946),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Thanh toán thất bại',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 30,
                                fontFamily: 'Afacad',
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              info.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 16,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                height: 1.63,
                              ),
                            ),
                            const SizedBox(height: 24),
                            PaymentFailedSummaryCard(
                              amount: _formatPrice(info.amount),
                              paymentMethod: info.paymentMethod,
                              lockerHub: info.lockerHub,
                              reason: info.reason,
                              referenceCode: info.referenceCode,
                            ),
                            const SizedBox(height: 20),
                            const PaymentFailedHintCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 88,
                  child: PaymentFailedActionButton(
                    label: 'Thanh toán lại',
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed('/payment'),
                    backgroundColor: const Color(0xFFE63946),
                    textColor: Colors.white,
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: PaymentFailedActionButton(
                    label: 'Thay đổi phương thức thanh toán',
                    onTap: () => Navigator.of(context).pop(),
                    backgroundColor: const Color(0xFFE63946),
                    textColor: const Color(0xFFE63946),
                    outlined: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
