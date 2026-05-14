import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'controllers/delivery_cubit.dart';
import 'controllers/delivery_state.dart';
import 'widgets/index.dart';

class SendReceiveScreen extends StatelessWidget {
  const SendReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryCubit, DeliveryState>(
      listener: (context, state) {
        final message = state.feedbackMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(message)));

          if (message.startsWith('Đã tạo yêu cầu gửi hàng')) {
            Navigator.of(context).pushNamed('/photo-confirmation');
          }
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF27B50)),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.80),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            title: const Text(
              'Gửi & Nhận hàng',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeliverySectionHeader(
                  title: 'Gửi hàng mới',
                  actionLabel: 'Hướng dẫn',
                  onActionTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mở hướng dẫn gửi hàng')),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn kích thước tủ phù hợp với kiện hàng',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.packageSizes.map((packageSize) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DeliveryPackageCard(
                            packageSize: packageSize,
                            selected: state.selectedSizeId == packageSize.id,
                            onTap: () => context
                                .read<DeliveryCubit>()
                                .selectSize(packageSize.id),
                          ),
                        );
                      }),
                      TextField(
                        onChanged: context.read<DeliveryCubit>().updateSendCode,
                        decoration: const InputDecoration(
                          labelText: 'Mã đơn gửi (tuỳ chọn)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.read<DeliveryCubit>().submitSendRequest(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF27B50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Xác nhận gửi hàng',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Nhận hàng',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nhập mã nhận hàng',
                        style: TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 14,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged:
                            context.read<DeliveryCubit>().updateReceiveCode,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontFamily: 'Liberation Mono',
                          letterSpacing: 0.9,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          hintText: 'EBOX-XXXXXX',
                          hintStyle: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 18,
                            fontFamily: 'Liberation Mono',
                            letterSpacing: 0.9,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context
                              .read<DeliveryCubit>()
                              .submitReceiveRequest(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF27B50),
                            side: const BorderSide(
                                color: Color(0xFFF27B50), width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Gửi',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child:
                                Divider(color: Color(0xFFF1F5F9), thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'HOẶC',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                          const Expanded(
                            child:
                                Divider(color: Color(0xFFF1F5F9), thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/qr-scanner'),
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text(
                            'Quét QR để nhận',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF27B50),
                            side: const BorderSide(
                                color: Color(0xFFF27B50), width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const DeliveryBanner(),
              ],
            ),
          ),
        );
      },
    );
  }
}
