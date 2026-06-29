import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'controllers/delivery_cubit.dart';
import 'controllers/delivery_state.dart';
import 'widgets/delivery_banner.dart';
import 'widgets/delivery_package_card.dart';
import 'widgets/delivery_section_header.dart';
import '../../locker_overdue_penalty/presentation/pages/locker_overdue_page.dart';

class SendReceiveScreen extends StatelessWidget {
  const SendReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryCubit, DeliveryState>(
      listener: (context, state) {
        final message = state.feedbackMessage;
        if (message == null) {
          return;
        }

        if (message.startsWith('Đã tạo yêu cầu gửi hàng')) {
          final lockerId = _extractLockerId(message);
          _showSuccessDialog(context, message, lockerId);
          return;
        }

        if (message.startsWith('LOCKER_OVERDUE:')) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LockerOverduePage()));
          return;
        }

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F7F6),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF27B50)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F7F6),
          appBar: AppBar(
            backgroundColor: const Color(0xE5F8F7F6),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 0,
            leadingWidth: 56,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
            title: const Text(
              'Gửi & Nhận hàng',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                height: 1.56,
              ),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: Color(0x19EE8C2B)),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                const SizedBox(height: 12),
                _PanelCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn kích thước tủ phù hợp với kiện hàng',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.packageSizes.map(
                        (packageSize) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DeliveryPackageCard(
                            packageSize: packageSize,
                            selected: state.selectedSizeId == packageSize.id,
                            onTap: () => context
                                .read<DeliveryCubit>()
                                .selectSize(packageSize.id),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Chọn tủ trống',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: state.lockers
                              .map((l) => l.location)
                              .toSet()
                              .map(
                                (location) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(location),
                                    selected:
                                        state.selectedLocation == location,
                                    onSelected: (selected) {
                                      context
                                          .read<DeliveryCubit>()
                                          .selectLocation(location);
                                    },
                                    selectedColor: const Color(0xFFF27B50),
                                    labelStyle: TextStyle(
                                      color: state.selectedLocation == location
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                      fontSize: 12,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                        itemCount: state.lockers
                            .where(
                              (l) =>
                                  state.selectedLocation == null ||
                                  l.location == state.selectedLocation,
                            )
                            .length,
                        itemBuilder: (context, index) {
                          final locker = state.lockers
                              .where(
                                (l) =>
                                    state.selectedLocation == null ||
                                    l.location == state.selectedLocation,
                              )
                              .toList()[index];
                          final isSelected =
                              state.selectedLockerId == locker.id;
                          final isOccupied = locker.isOccupied;

                          return GestureDetector(
                            onTap: isOccupied
                                ? null
                                : () => context
                                      .read<DeliveryCubit>()
                                      .selectLocker(locker.id, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF27B50)
                                    : (isOccupied
                                          ? const Color(0xFFF1F5F9)
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF27B50)
                                      : (isOccupied
                                            ? const Color(0xFFE2E8F0)
                                            : const Color(0xFFF1F5F9)),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  locker.code,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isOccupied
                                              ? Colors.grey
                                              : const Color(0xFF0F172A)),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (state.selectedLockerId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Color(0xFFFB923C),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.lockers
                                      .firstWhere(
                                        (l) => l.id == state.selectedLockerId,
                                      )
                                      .location,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: context
                            .read<DeliveryCubit>()
                            .updateSenderName,
                        decoration: InputDecoration(
                          labelText: 'Tên người gửi',
                          labelStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFF27B50),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: context
                            .read<DeliveryCubit>()
                            .updateReceiverPhone,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại người nhận',
                          labelStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFF27B50),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.read<DeliveryCubit>().submitSendRequest(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF27B50),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: const Text(
                            'Xác nhận gửi hàng',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              height: 1.5,
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
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                  ),
                ),
                const SizedBox(height: 12),
                _PanelCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nhập mã nhận hàng',
                        style: TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: context
                            .read<DeliveryCubit>()
                            .updateReceiveCode,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontFamily: 'Liberation Mono',
                          letterSpacing: 0.9,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          hintText: 'EBOX-XXXXXX',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 18,
                            fontFamily: 'Liberation Mono',
                            letterSpacing: 0.9,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFF27B50),
                              width: 1.5,
                            ),
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
                              color: Color(0xFFF27B50),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: const Text(
                            'Gửi',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFF1F5F9),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'HOẶC',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFF1F5F9),
                              thickness: 1,
                            ),
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
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF27B50),
                            side: const BorderSide(
                              color: Color(0xFFF27B50),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
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

  String? _extractLockerId(String message) {
    final match = RegExp(r'Locker ID:\s+([a-f0-9-]+)').firstMatch(message);
    return match?.group(1)?.trim();
  }

  void _showSuccessDialog(
    BuildContext context,
    String message,
    String? lockerId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFF27B50), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Thành công!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Plus Jakarta Sans',
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                if (lockerId != null) {
                  Navigator.of(
                    context,
                  ).pushNamed('/photo-confirmation', arguments: lockerId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF27B50),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tiếp tục',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final Widget child;

  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x0D000000),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: const Color(0xFF0F172A)),
        ),
      ),
    );
  }
}
