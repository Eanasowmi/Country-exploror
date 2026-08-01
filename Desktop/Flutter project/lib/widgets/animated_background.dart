import 'dart:math';
import 'package:flutter/material.dart';

/// A reusable animated background with floating glowing orbs + shifting gradient.
/// Wrap your Scaffold body with this widget.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const AnimatedBackground({
    Key? key,
    required this.child,
    required this.isDark,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientCtrl;
  late AnimationController _orbCtrl;
  late List<_Orb> _orbs;

  @override
  void initState() {
    super.initState();

    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    final rng = Random(42);
    _orbs = List.generate(6, (i) {
      return _Orb(
        startX: rng.nextDouble(),
        startY: rng.nextDouble(),
        radius: 60 + rng.nextDouble() * 80,
        speed: 0.04 + rng.nextDouble() * 0.06,
        phase: rng.nextDouble() * 2 * pi,
        color: _orbColors(i, widget.isDark),
      );
    });
  }

  Color _orbColors(int i, bool isDark) {
    final lightColors = [
      const Color(0xFF38BDF8).withOpacity(0.25),
      const Color(0xFF7DD3FC).withOpacity(0.20),
      const Color(0xFFBAE6FD).withOpacity(0.30),
      const Color(0xFF93C5FD).withOpacity(0.20),
      const Color(0xFF6EE7B7).withOpacity(0.15),
      const Color(0xFFA5F3FC).withOpacity(0.22),
    ];
    final darkColors = [
      const Color(0xFF0EA5E9).withOpacity(0.12),
      const Color(0xFF0284C7).withOpacity(0.10),
      const Color(0xFF38BDF8).withOpacity(0.08),
      const Color(0xFF6366F1).withOpacity(0.10),
      const Color(0xFF059669).withOpacity(0.08),
      const Color(0xFF7C3AED).withOpacity(0.08),
    ];
    return isDark ? darkColors[i % darkColors.length] : lightColors[i % lightColors.length];
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final pageBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F9FF);

    return AnimatedBuilder(
      animation: Listenable.merge([_gradientCtrl, _orbCtrl]),
      builder: (context, _) {
        final t = _gradientCtrl.value;
        final orbT = _orbCtrl.value;
        final size = MediaQuery.of(context).size;

        return Stack(
          children: [
            // ── Shifting gradient background ─────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? RadialGradient(
                        center: Alignment(-0.6 + t * 1.2, -0.4 + t * 0.8),
                        radius: 1.6,
                        colors: [
                          Color.lerp(const Color(0xFF0F2A4A), const Color(0xFF0F172A), t)!,
                          const Color(0xFF0F172A),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment(-1.0 + t * 0.4, -1.0 + t * 0.2),
                        end: Alignment(1.0 - t * 0.4, 1.0 - t * 0.2),
                        colors: [
                          Color.lerp(const Color(0xFFE0F2FE), const Color(0xFFBAE6FD), t)!,
                          Color.lerp(const Color(0xFFF0F9FF), const Color(0xFFE0F2FE), t)!,
                          Color.lerp(const Color(0xFFE0F2FE), const Color(0xFFDBEAFE), t)!,
                        ],
                      ),
              ),
            ),

            // ── Floating glowing orbs ─────────────────────────────────
            ..._orbs.map((orb) {
              final angle = orbT * 2 * pi * orb.speed * 10 + orb.phase;
              final dx = orb.startX * size.width +
                  sin(angle) * size.width * 0.12;
              final dy = orb.startY * size.height +
                  cos(angle * 0.7) * size.height * 0.10;

              return Positioned(
                left: dx - orb.radius,
                top: dy - orb.radius,
                child: Container(
                  width: orb.radius * 2,
                  height: orb.radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        orb.color,
                        orb.color.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // ── Actual content on top ─────────────────────────────────
            widget.child,
          ],
        );
      },
    );
  }
}

class _Orb {
  final double startX;
  final double startY;
  final double radius;
  final double speed;
  final double phase;
  final Color color;

  const _Orb({
    required this.startX,
    required this.startY,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.color,
  });
}
