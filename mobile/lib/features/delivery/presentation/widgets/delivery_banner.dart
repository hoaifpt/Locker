import 'package:flutter/material.dart';

class DeliveryBanner extends StatelessWidget {
  const DeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0x19F27B50),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 128,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x33F27B50),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(9999),
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ưu đãi hôm nay',
                style: TextStyle(
                  color: Color(0xFFF27B50),
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Giảm 20% cho đơn gửi đầu tiên',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}