import 'package:flutter/material.dart';

class SecurityPrivacyPrivacyCard extends StatelessWidget {
  const SecurityPrivacyPrivacyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      padding: const EdgeInsets.all(32),
      decoration: ShapeDecoration(
        color: const Color(0x7FFFF7ED),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Colors.white),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Quyền riêng tư dữ liệu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9D4320),
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.56,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'E-BOX cam kết bảo vệ dữ liệu cá\nnhân của bạn. Chúng tôi không bao\ngiờ chia sẻ thông tin vị trí hay mã tủ\nđồ cho bên thứ ba.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF52443E),
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              height: 1.63,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0x339D4320)),
                borderRadius: BorderRadius.circular(9999),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: const Text(
              'Xem chính sách chi tiết',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9D4320),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                height: 1.43,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
