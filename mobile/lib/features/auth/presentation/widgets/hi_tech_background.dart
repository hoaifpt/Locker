import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Hi-tech background for the login screen: dark cam-đen backdrop with
/// animated vertical light rays drifting up/down and soft orange glow
/// blobs. Inspired by cyberpunk loading screens — gives a "scanning"
/// feel without distracting from the form on top.
///
/// Performance notes
/// - Pure `CustomPaint` + `AnimatedBuilder`, no widgets get rebuilt
///   inside the ray loop (just `Transform.translate` on cached rects).
/// - `RepaintBoundary` wraps the painter so the form above is not
///   repainted every frame.
class HiTechBackground extends StatefulWidget {
  final Widget child;
  const HiTechBackground({super.key, required this.child});

  @override
  State<HiTechBackground> createState() => _HiTechBackgroundState();
}

class _HiTechBackgroundState extends State<HiTechBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Ray> _rays;
  late final List<_ScanLine> _scanLines;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Pseudo-random but deterministic so the layout is stable across
    // rebuilds.
    final rng = math.Random(42);

    // 6 vertical light rays drifting vertically, alternating up/down.
    _rays = List.generate(6, (i) {
      final down = i.isEven;
      return _Ray(
        horizontalFraction: 0.08 + rng.nextDouble() * 0.84,
        width: 0.6 + rng.nextDouble() * 1.4, // 0.6 – 2 px
        heightFraction: 0.18 + rng.nextDouble() * 0.32, // 18 – 50 % of h
        opacity: 0.06 + rng.nextDouble() * 0.18,
        speed: 0.35 + rng.nextDouble() * 0.55, // cycles per loop
        driftDown: down,
        phase: rng.nextDouble(),
        color: i.isEven
            ? const Color(0xFFFB923C) // orange-400
            : const Color(0xFFFCA76B), // softer peach
      );
    });

    // 4 horizontal scanline strips that fade in/out across the screen.
    _scanLines = List.generate(4, (i) {
      return _ScanLine(
        verticalFraction: 0.15 + rng.nextDouble() * 0.7,
        height: 1.0 + rng.nextDouble() * 1.5,
        opacity: 0.05 + rng.nextDouble() * 0.08,
        speed: 0.4 + rng.nextDouble() * 0.4,
        phase: rng.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Base fill: deep, almost-black cam so the orange rays pop.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0E08),
            Color(0xFF241008),
            Color(0xFF1A0E08),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Animated rays + scanlines + glow blobs in one CustomPaint.
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _HiTechPainter(
                    t: _controller.value,
                    rays: _rays,
                    scanLines: _scanLines,
                  ),
                );
              },
            ),
          ),
          // Vignette to darken the edges and focus the eye on the form.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
          // Real content on top.
          widget.child,
        ],
      ),
    );
  }
}

class _Ray {
  final double horizontalFraction;
  final double width;
  final double heightFraction;
  final double opacity;
  final double speed;
  final bool driftDown;
  final double phase;
  final Color color;

  const _Ray({
    required this.horizontalFraction,
    required this.width,
    required this.heightFraction,
    required this.opacity,
    required this.speed,
    required this.driftDown,
    required this.phase,
    required this.color,
  });
}

class _ScanLine {
  final double verticalFraction;
  final double height;
  final double opacity;
  final double speed;
  final double phase;

  const _ScanLine({
    required this.verticalFraction,
    required this.height,
    required this.opacity,
    required this.speed,
    required this.phase,
  });
}

class _HiTechPainter extends CustomPainter {
  final double t;
  final List<_Ray> rays;
  final List<_ScanLine> scanLines;

  _HiTechPainter({
    required this.t,
    required this.rays,
    required this.scanLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft orange glow blobs (static, painted first so rays render on top)
    _paintGlow(canvas, size, Alignment.topLeft, const Color(0xFFFB923C), 0.45);
    _paintGlow(
      canvas,
      size,
      Alignment.bottomRight,
      const Color(0xFFF97316),
      0.35,
    );
    _paintGlow(
      canvas,
      size,
      const Alignment(0.6, -0.8),
      const Color(0xFFFFB07A),
      0.25,
    );

    // 2. Vertical light rays — translate Y over time, looped.
    for (final r in rays) {
      final cycle = (t * r.speed + r.phase) % 1.0;
      // Map cycle 0..1 → -h..h so the ray fully crosses the screen.
      final travel = size.height * 1.4;
      final baseY = -size.height * 0.3 + (cycle * travel);
      // Skip rendering when the ray is fully off-screen.
      final rayHeight = size.height * r.heightFraction;
      if (baseY + rayHeight < 0 || baseY > size.height) continue;

      final x = size.width * r.horizontalFraction;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: r.driftDown ? Alignment.topCenter : Alignment.bottomCenter,
          end: r.driftDown ? Alignment.bottomCenter : Alignment.topCenter,
          colors: [
            r.color.withValues(alpha: 0.0),
            r.color.withValues(alpha: r.opacity),
            r.color.withValues(alpha: r.opacity * 0.6),
            r.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 0.6, 1.0],
        ).createShader(
          Rect.fromLTWH(x - r.width / 2, baseY, r.width, rayHeight),
        );
      canvas.drawRect(
        Rect.fromLTWH(x - r.width / 2, baseY, r.width, rayHeight),
        paint,
      );

      // Glow halo (wider, softer).
      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: r.driftDown ? Alignment.topCenter : Alignment.bottomCenter,
          end: r.driftDown ? Alignment.bottomCenter : Alignment.topCenter,
          colors: [
            r.color.withValues(alpha: 0.0),
            r.color.withValues(alpha: r.opacity * 0.18),
            r.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromLTWH(x - 14, baseY, 28, rayHeight),
        );
      canvas.drawRect(
        Rect.fromLTWH(x - 14, baseY, 28, rayHeight),
        glowPaint,
      );
    }

    // 3. Horizontal scanlines — slow fade in/out.
    for (final s in scanLines) {
      final cycle = (t * s.speed + s.phase) % 1.0;
      // Triangle wave 0..1..0 so the line fades in then out.
      final tri = 1.0 - (cycle * 2 - 1).abs();
      final alpha = s.opacity * tri;
      if (alpha < 0.005) continue;
      final y = size.height * s.verticalFraction;
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFB923C).withValues(alpha: 0.0),
            const Color(0xFFFB923C).withValues(alpha: alpha),
            const Color(0xFFFB923C).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromLTWH(0, y - s.height / 2, size.width, s.height),
        );
      canvas.drawRect(
        Rect.fromLTWH(0, y - s.height / 2, size.width, s.height),
        paint,
      );
    }
  }

  void _paintGlow(
    Canvas canvas,
    Size size,
    Alignment align,
    Color color,
    double alpha,
  ) {
    final dx = align.x * size.width;
    final dy = align.y * size.height;
    final radius = size.shortestSide * 0.85;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(dx, dy), radius: radius),
      );
    canvas.drawCircle(Offset(dx, dy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _HiTechPainter old) =>
      old.t != t || old.rays != rays || old.scanLines != scanLines;
}