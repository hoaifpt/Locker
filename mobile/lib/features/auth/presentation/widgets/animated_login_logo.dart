import 'package:flutter/material.dart';

/// Lightweight animation around the ebox_logo asset: subtle scale pulse
/// + warm orange glow halo so the brand mark feels alive without
/// requiring an actual GIF/Lottie file (the repo currently only has
/// static PNGs).
///
/// - Pulse: 1.0 → 1.05 → 1.0 over 2.4s, ease-in-out, infinite.
/// - Glow: soft orange radial halo whose opacity follows the same
///   sine curve, so it breathes in sync with the scale.
/// - The underlying image still comes from assets/ebox_logo.png, so
///   asset size and startup cost are unchanged.
class AnimatedLoginLogo extends StatefulWidget {
  final double size;
  final String assetPath;

  const AnimatedLoginLogo({
    super.key,
    required this.size,
    this.assetPath = 'assets/ebox_logo.png',
  });

  @override
  State<AnimatedLoginLogo> createState() => _AnimatedLoginLogoState();
}

class _AnimatedLoginLogoState extends State<AnimatedLoginLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Ease-in-out so the breathing motion feels natural.
    final eased = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(eased);
    _glow = Tween<double>(begin: 0.35, end: 0.85).animate(eased);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Soft glow halo behind the logo. Radial gradient gives a
              // cinematic bloom look; sized larger than the logo so the
              // halo extends past its bounds.
              Container(
                width: widget.size * 1.4,
                height: widget.size * 1.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFB923C).withValues(alpha: _glow.value),
                      const Color(0xFFFB923C).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
              Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            ],
          );
        },
        child: Image.asset(
          widget.assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.inbox,
            size: 80,
            color: Color(0xFFEB6C4B),
          ),
        ),
      ),
    );
  }
}