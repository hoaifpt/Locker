import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Khung QR 256x256 với 4 góc cam + đường scan line chạy lên xuống (animation)
class ScannerViewfinder extends StatefulWidget {
  const ScannerViewfinder({super.key});

  @override
  State<ScannerViewfinder> createState() => _ScannerViewfinderState();
}

class _ScannerViewfinderState extends State<ScannerViewfinder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0, end: 240).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 256,
      child: Stack(
        children: [
          // Đường scan line chạy dọc
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                left: 1,
                top: _scanAnimation.value,
                child: Container(
                  width: 254,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0x00FF7043),
                        AppColors.scannerAccent,
                        Color(0x00FF7043),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.scannerAccent,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 4 góc bracket
          _Corner(
              alignment: Alignment.topLeft,
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(24))),
          _Corner(
              alignment: Alignment.topRight,
              borderRadius:
                  const BorderRadius.only(topRight: Radius.circular(24))),
          _Corner(
              alignment: Alignment.bottomLeft,
              borderRadius:
                  const BorderRadius.only(bottomLeft: Radius.circular(24))),
          _Corner(
              alignment: Alignment.bottomRight,
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(24))),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;
  final BorderRadius borderRadius;
  const _Corner({required this.alignment, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 48,
        height: 48,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 4, color: AppColors.scannerAccent),
            borderRadius: borderRadius,
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x99FF7043),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
