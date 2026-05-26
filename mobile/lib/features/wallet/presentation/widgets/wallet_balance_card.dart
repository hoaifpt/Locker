import 'package:flutter/material.dart';

class WalletBalanceCard extends StatelessWidget {
  final int balance;
  final int monthlyChange;
  final int points;
  final VoidCallback onTopUp;
  final VoidCallback onWithdraw;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.monthlyChange,
    required this.points,
    required this.onTopUp,
    required this.onWithdraw,
  });

  String _formatMoney(int value) {
    final isNegative = value < 0;
    final absoluteValue = value.abs();
    final formatted = absoluteValue.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '${isNegative ? '-' : ''}$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xE5FFFFFF),
            blurRadius: 24,
            offset: Offset(-8, -8),
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(8, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -48,
            top: -48,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                color: const Color(0x0C87503C),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Positioned(
            left: -48,
            top: 78,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                color: const Color(0x0C9D4320),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'SỐ DƯ HIỆN TẠI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF52443E),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    height: 1.43,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatMoney(balance),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFD8D64),
                      fontSize: 36,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      height: 1.11,
                      letterSpacing: -1.8,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'đ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFD8D64),
                        fontSize: 20,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Nạp tiền',
                      icon: Icons.add_circle_outline_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFD8D64), Color(0xFF9D4320)],
                      ),
                      onTap: onTopUp,
                      labelColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'Rút tiền',
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFFF3F3F4),
                      onTap: onWithdraw,
                      labelColor: const Color(0xFF1A1C1C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _InfoCard(
                          title: 'THÁNG NÀY',
                          value: '${_formatMoney(monthlyChange)}đ')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _InfoCard(title: 'E-POINTS', value: '$points')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final LinearGradient? gradient;
  final Color? color;
  final Color labelColor;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.labelColor,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: gradient,
      color: color,
      boxShadow: gradient != null
          ? const [
              BoxShadow(
                color: Color(0x339D4320),
                blurRadius: 15,
                offset: Offset(0, 10),
                spreadRadius: -3,
              ),
            ]
          : null,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: decoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: labelColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x26DEC0B7),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: const Color(0x4CC6C6C6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child:
                const Icon(Icons.bar_chart_rounded, color: Color(0xFF52443E)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF52443E),
              fontSize: 11,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.5,
              letterSpacing: 0.55,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1C1C),
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.56,
            ),
          ),
        ],
      ),
    );
  }
}
