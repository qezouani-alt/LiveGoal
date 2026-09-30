import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The floating-dot wallpaper used across the app and its startup screens.
class AppWallpaper extends StatefulWidget {
  const AppWallpaper({super.key});

  @override
  State<AppWallpaper> createState() => _AppWallpaperState();
}

class _AppWallpaperState extends State<AppWallpaper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ColoredBox(
        color: Colors.white,
        child: AnimatedBuilder(
          animation: _controller,
          builder:
              (context, child) => CustomPaint(
                painter: ColorfulDotsPainter(_controller.value),
                child: const SizedBox.expand(),
              ),
        ),
      ),
    );
  }
}

class ColorfulDotsPainter extends CustomPainter {
  final double animationValue;

  const ColorfulDotsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFF45B7D1),
      Color(0xFF96CEB4),
      Color(0xFFFECA57),
      Color(0xFFFF9FF3),
      Color(0xFF54A0FF),
      Color(0xFF5F27CD),
      Color(0xFF00D2D3),
      Color(0xFFFF9F43),
    ];

    for (var i = 0; i < 20; i++) {
      final x = (i * 150.0 + animationValue * 100) % size.width;
      final y = (i * 100.0 + animationValue * 80) % size.height;
      final dotSize = 1.5 + (i % 3) * 1.0;
      final movementX = math.sin(animationValue * 1.2 * math.pi + i) * 40;
      final movementY = math.cos(animationValue * 1.8 * math.pi + i) * 30;
      final dot = Offset(
        (x + movementX) % size.width,
        (y + movementY) % size.height,
      );
      final color = colors[i % colors.length];
      final twinkle = (math.sin(animationValue * 3 * math.pi + i) + 1) / 2;

      paint.color = color.withValues(alpha: 0.6 + twinkle * 0.4);
      canvas.drawCircle(dot, dotSize, paint);
      paint.color = color.withValues(alpha: 0.1);
      canvas.drawCircle(dot, dotSize * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ColorfulDotsPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
