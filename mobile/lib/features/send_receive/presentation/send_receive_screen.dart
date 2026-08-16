import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/extensions/context_extensions.dart';
import '../../locker/domain/entities/locker_slot.dart';
import '../../locker/domain/entities/locker.dart'; // Giả định bạn có entity này
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

  bool _orderHandled = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendReceiveCubit, SendReceiveState>(
      listenWhen: (prev, next) =>
          prev.currentOrder != next.currentOrder ||
          prev.errorMessage != next.errorMessage,
      listener: (context, state) async {
        // Chỉ lắng nghe sau khi đã tải xong dữ liệu ban đầu
        if (state.lockerSizes.isEmpty) return;

        // Capture navigator + cubit TRƯỚC khi await để tránh
        // use_build_context_synchronously khi dùng context sau dialog.
        final navigator = Navigator.of(context);
        final cubit = context.read<SendReceiveCubit>();

        if (state.currentOrder != null && !_orderHandled) {
          _orderHandled = true;
          // Tạo đơn hàng thành công → show dialog có mã đơn + nút Copy
          // trước khi điều hướng sang trang thanh toán.
          final order = state.currentOrder!;
          final orderData = {
            'orderId': order.id,
            'lockerCode': order.lockerCode,
            'location': order.location,
            'size': order.size,
            'duration': order.duration,
            'storagePrice': order.size.price,
            'servicePrice': 2000, // Tạm thời hardcode, nên lấy từ API nếu có
            'totalPrice': order.estimatedFee,
          };
          await context.showCopyDialog(
            title: 'Tạo đơn hàng thành công',
            code: order.id,
            subtitle: 'Vui lòng sao chép mã đơn hàng để tra cứu khi cần.',
            description: 'Bạn có thể tìm lại mã này trong mục "Đơn hàng của tôi".',
          );
          navigator.pushNamed('/payment', arguments: orderData);
          _orderHandled = false;
        } else if (state.errorMessage != null) {
          // Alert thân thiện thay vì snackbar raw text.
          await context.showAlert(
            state.errorMessage!,
            title: 'Tạo đơn hàng thất bại',
            type: AlertType.error,
          );
          // Xóa lỗi để không hiển thị lại
          cubit.clearError();
        }
      },
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
        final selectedLocker = state.selectedLockerId != null
            ? state.lockers.firstWhere(
                (l) => l.id == state.selectedLockerId,
                orElse: () => Locker.empty,
              )
            : null;

        final previewOrder =
            selectedSize != null &&
                selectedDuration != null &&
                selectedLocker != null &&
                state.selectedSlotIndex != null
            ? SendReceiveOrder(
                id: 'preview-order',
                lockerId: selectedLocker.id,
                lockerCode: 'Ngăn ${state.selectedSlotIndex}',
                location: selectedLocker.location, // Lấy vị trí thật
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
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF111827),
              ),
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
                // Thêm Dropdown để chọn trạm tủ
                DropdownButtonFormField<String>(
                  initialValue: state.selectedLockerId,
                  isExpanded: true,
                  hint: const Text(
                    '1. Chọn trạm tủ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (lockerId) {
                    if (lockerId != null) {
                      context.read<SendReceiveCubit>().selectLocker(lockerId);
                    }
                  },
                  items: state.lockers.map((locker) {
                    return DropdownMenuItem<String>(
                      value: locker.id,
                      child: Text(locker.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Thêm Dropdown để chọn ngăn tủ
                DropdownButtonFormField<int>(
                  initialValue: state.selectedSlotIndex,
                  isExpanded: true,
                  hint: Text(
                    '2. Chọn ngăn tủ trống',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: state.selectedLockerId == null
                          ? Colors.grey.shade400
                          : null,
                    ),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: state.selectedLockerId == null
                      ? null
                      : (slotIndex) {
                          context.read<SendReceiveCubit>().selectSlot(
                            slotIndex,
                          );
                        },
                  items:
                      state.selectedLocker?.slots
                          .where(
                            (slot) =>
                                slot.isAvailable &&
                                slot.size == state.selectedSize?.size,
                          )
                          .map((LockerSlot slot) {
                            return DropdownMenuItem<int>(
                              value: slot.index,
                              child: Text(
                                'Ngăn số ${slot.index} (Cỡ ${slot.size})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .toList() ??
                      [],
                ),
                const SizedBox(height: 24),
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
                    ? () => context.read<SendReceiveCubit>().createOrder()
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
                child: state.isLoading && state.lockerSizes.isNotEmpty
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Tiếp tục & Thanh toán',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
