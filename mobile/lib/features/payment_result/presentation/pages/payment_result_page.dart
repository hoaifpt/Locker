import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/payment_result.dart';

class PaymentResultPage extends StatelessWidget {
  const PaymentResultPage({super.key, required this.request});

  final PaymentResultRequest request;

  String _formatAmount(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '$formatted đ';
  }

  @override
  Widget build(BuildContext context) {
    final appearance = _ResultAppearance.from(request.status);

    return Scaffold(
      backgroundColor: const Color(0xFF10141C),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF292929)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 36,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(gradient: appearance.gradient),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                      child: Column(
                        children: [
                          Semantics(
                            label: appearance.title,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: appearance.glowColor,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(9),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: appearance.color,
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    request.status ==
                                        PaymentResultStatus.pending
                                    ? const _PendingSpinner()
                                    : Icon(
                                        appearance.icon,
                                        color: Colors.white,
                                        size: 45,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            appearance.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              height: 1.25,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (request.amount > 0) ...[
                            const SizedBox(height: 12),
                            Text(
                              _formatAmount(request.amount),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            request.message ?? appearance.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFA3A3A3),
                              fontSize: 14,
                              height: 1.55,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _ReferenceChip(
                            code: request.referenceCode,
                            onCopy: () =>
                                _copyReference(context, request.referenceCode),
                          ),
                          const SizedBox(height: 28),
                          _DetailsCard(
                            amount: request.amount > 0
                                ? _formatAmount(request.amount)
                                : null,
                            orderCode: request.orderCode,
                            referenceCode: request.referenceCode,
                            paymentMethod: request.paymentMethod,
                            lockerHub: request.lockerHub,
                            accentColor: appearance.color,
                          ),
                          const SizedBox(height: 28),
                          _ActionButtons(
                            appearance: appearance,
                            onPrimary: () => _handlePrimary(context),
                            onSecondary: () => _goHome(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyReference(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép mã giao dịch'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handlePrimary(BuildContext context) {
    if (request.status == PaymentResultStatus.success) {
      _goHome(context);
      return;
    }

    if (request.status == PaymentResultStatus.pending) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/wallet', (route) => false);
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _goHome(context);
    }
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}

class _PendingSpinner extends StatelessWidget {
  const _PendingSpinner();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(23),
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 4,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}

class _ReferenceChip extends StatelessWidget {
  const _ReferenceChip({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF292929),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mã giao dịch: ',
                style: TextStyle(
                  color: Color(0xFFD4D4D4),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Flexible(
                child: Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.copy_rounded,
                size: 15,
                color: Color(0xFFA3A3A3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.amount,
    required this.orderCode,
    required this.referenceCode,
    required this.paymentMethod,
    required this.lockerHub,
    required this.accentColor,
  });

  final String? amount;
  final String? orderCode;
  final String referenceCode;
  final String? paymentMethod;
  final String? lockerHub;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final details = <(String, String, bool)>[
      if (amount != null) ('Số tiền', amount!, true),
      ('Mã đơn hàng', orderCode ?? referenceCode, false),
      if (paymentMethod?.trim().isNotEmpty == true)
        ('Phương thức', paymentMethod!, false),
      if (lockerHub?.trim().isNotEmpty == true)
        ('Locker Hub', lockerHub!, false),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2B2B2B)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var index = 0; index < details.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      details[index].$1,
                      style: const TextStyle(
                        color: Color(0xFFA3A3A3),
                        fontSize: 13,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      details[index].$2,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: details[index].$3 ? accentColor : Colors.white,
                        fontSize: 13,
                        fontFamily: details[index].$1 == 'Mã đơn hàng'
                            ? 'monospace'
                            : 'Manrope',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (index != details.length - 1)
              const Divider(height: 1, color: Color(0xFF292929)),
          ],
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.appearance,
    required this.onPrimary,
    required this.onSecondary,
  });

  final _ResultAppearance appearance;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final primary = _ResultButton(
          label: appearance.primaryLabel,
          icon: appearance.primaryIcon,
          onTap: onPrimary,
          backgroundColor: appearance.color,
          foregroundColor: Colors.white,
        );
        final secondary = _ResultButton(
          label: 'Quay về trang chủ',
          icon: Icons.arrow_back_rounded,
          onTap: onSecondary,
          backgroundColor: const Color(0xFF292929),
          foregroundColor: Colors.white,
        );

        if (compact) {
          return Column(
            children: [
              SizedBox(width: double.infinity, child: primary),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: secondary),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: secondary),
            const SizedBox(width: 12),
            Expanded(child: primary),
          ],
        );
      },
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 50),
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}

class _ResultAppearance {
  const _ResultAppearance({
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.icon,
    required this.color,
    required this.glowColor,
    required this.gradient,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final IconData primaryIcon;
  final IconData icon;
  final Color color;
  final Color glowColor;
  final LinearGradient gradient;

  factory _ResultAppearance.from(PaymentResultStatus status) {
    return switch (status) {
      PaymentResultStatus.success => const _ResultAppearance(
        title: 'Thanh toán thành công',
        message: 'Giao dịch đã hoàn tất và được ghi nhận an toàn.',
        primaryLabel: 'Hoàn tất',
        primaryIcon: Icons.home_rounded,
        icon: Icons.check_rounded,
        color: Color(0xFF00C896),
        glowColor: Color(0x2634D399),
        gradient: LinearGradient(
          colors: [Color(0xFF00C896), Color(0xFF6366F1)],
        ),
      ),
      PaymentResultStatus.failed => const _ResultAppearance(
        title: 'Thanh toán thất bại',
        message: 'Giao dịch chưa được thực hiện. Tài khoản chưa bị trừ tiền.',
        primaryLabel: 'Thanh toán lại',
        primaryIcon: Icons.refresh_rounded,
        icon: Icons.close_rounded,
        color: Color(0xFFEF4444),
        glowColor: Color(0x26EF4444),
        gradient: LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF97316)],
        ),
      ),
      PaymentResultStatus.cancelled => const _ResultAppearance(
        title: 'Thanh toán đã bị hủy',
        message: 'Bạn đã hủy giao dịch trước khi thanh toán hoàn tất.',
        primaryLabel: 'Thử lại',
        primaryIcon: Icons.replay_rounded,
        icon: Icons.block_rounded,
        color: Color(0xFFF97316),
        glowColor: Color(0x26F97316),
        gradient: LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
        ),
      ),
      PaymentResultStatus.expired => const _ResultAppearance(
        title: 'Giao dịch đã hết hạn',
        message:
            'Thời gian thanh toán đã kết thúc. Vui lòng tạo lại giao dịch.',
        primaryLabel: 'Tạo lại giao dịch',
        primaryIcon: Icons.replay_rounded,
        icon: Icons.timer_off_rounded,
        color: Color(0xFFF59E0B),
        glowColor: Color(0x26F59E0B),
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
        ),
      ),
      PaymentResultStatus.pending => const _ResultAppearance(
        title: 'Đang chờ xử lý',
        message: 'Giao dịch đang được xác nhận. Vui lòng không thanh toán lại.',
        primaryLabel: 'Kiểm tra trong ví',
        primaryIcon: Icons.account_balance_wallet_rounded,
        icon: Icons.hourglass_top_rounded,
        color: Color(0xFF3B82F6),
        glowColor: Color(0x263B82F6),
        gradient: LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
        ),
      ),
    };
  }
}
