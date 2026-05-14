import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/send_receive_order.dart';
import 'controllers/send_receive_cubit.dart';
import 'controllers/send_receive_state.dart';
import 'pages/locker_size_page.dart';
import 'pages/storage_duration_page.dart';
import 'widgets/order_info_card.dart';

class SendReceiveScreen extends StatefulWidget {
  const SendReceiveScreen({super.key});

  @override
  State<SendReceiveScreen> createState() => _SendReceiveScreenState();
}

class _SendReceiveScreenState extends State<SendReceiveScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SendReceiveCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendReceiveCubit, SendReceiveState>(
      builder: (context, state) {
        if (state.isLoading && state.lockerSizes.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFFBF2),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFB923C)),
            ),
          );
        }

        if (state.errorMessage != null && state.lockerSizes.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFBF2),
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Gửi đồ vào tủ',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }

        final selectedSize = state.selectedSize;
        final selectedDuration = state.selectedDuration;

        final previewOrder = selectedSize != null && selectedDuration != null
            ? SendReceiveOrder(
                id: 'preview-order',
                lockerId: 'locker-001',
                lockerCode: 'Locker A-102',
                location: 'Thao Dien, District 2, HCMC',
                size: selectedSize,
                duration: selectedDuration,
                estimatedFee: selectedSize.price,
                status: 'preview',
                createdAt: DateTime.now(),
              )
            : null;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF2),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 52,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF111827)),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            centerTitle: false,
            title: const Text(
              'Gửi đồ vào tủ',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LockerSizePage(
                  sizes: state.lockerSizes,
                  selectedSizeId: state.selectedSizeId,
                  onSizeSelected: (sizeId) {
                    context.read<SendReceiveCubit>().selectSize(sizeId);
                  },
                ),
                const SizedBox(height: 24),
                StorageDurationPage(
                  durations: state.storageDurations,
                  selectedDurationId: state.selectedDurationId,
                  onDurationSelected: (durationId) {
                    context.read<SendReceiveCubit>().selectDuration(durationId);
                  },
                ),
                const SizedBox(height: 24),
                if (previewOrder != null) OrderInfoCard(order: previewOrder),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: state.canProceed && !state.isLoading
                    ? () {
                        final orderData = {
                          'lockerCode': 'Locker A-102',
                          'location': 'Khu vực sảnh A',
                          'size': state.selectedSize,
                          'duration': state.selectedDuration,
                          'storagePrice': state.selectedSize?.price ?? 0,
                          'servicePrice': 2000,
                          'totalPrice': (state.selectedSize?.price ?? 0) + 2000,
                        };
                        Navigator.of(context).pushNamed(
                          '/payment',
                          arguments: orderData,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9431),
                  disabledBackgroundColor: const Color(0xFFDBE1EA),
                  shadowColor: const Color(0x33FF9431),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: const Text(
                  'Tiếp tục & Thanh toán',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
