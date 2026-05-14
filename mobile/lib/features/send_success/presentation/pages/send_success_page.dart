import 'package:flutter/material.dart';

import '../../domain/entities/send_success_info.dart';

class SendSuccessPage extends StatelessWidget {
  final SendSuccessRequest? request;

  const SendSuccessPage({super.key, this.request});

  String _formatPin(String pin) {
    final digits = pin.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 6) {
      return '${digits.substring(0, 3)} - ${digits.substring(3, 6)}';
    }
    return pin;
  }

  @override
  Widget build(BuildContext context) {
    final data = SendSuccessInfo(
      title: 'Thành công!',
      message: 'Giao dịch của bạn đã hoàn tất.',
      lockerHub: request?.lockerHub ?? 'tủ B3-104',
      pin: request?.pin ?? '882109',
      amount: request?.amount,
      orderCode: request?.orderCode,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF5F0),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 36,
                    color: Color(0xFFF27B50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'MÃ QR NHẬN HÀNG CỦA BẠN',
                          style: TextStyle(
                            color: Color(0xFF7A8CA5),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF0E6E0)),
                            color: const Color(0xFFF8F5F3),
                          ),
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: Center(
                              child: data.orderCode != null &&
                                      data.orderCode!.isNotEmpty
                                  ? Text(
                                      data.orderCode!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.qr_code_2_outlined,
                                      size: 52,
                                      color: Color(0xFF94A3B8),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'MÃ PIN DỰ PHÒNG',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatPin(data.pin),
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFFF27B50),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: 'Vui lòng quét mã tại '),
                                    TextSpan(
                                      text: data.lockerHub,
                                      style: const TextStyle(
                                        color: Color(0xFFF27B50),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const TextSpan(text: ' để lấy đồ'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.download_outlined,
                              color: Color(0xFFF27B50),
                            ),
                            label: const Text(
                              'Lưu vào thư viện ảnh',
                              style: TextStyle(
                                color: Color(0xFFF27B50),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFF0E0D6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/home', (r) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF27B50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Quay lại trang chủ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
