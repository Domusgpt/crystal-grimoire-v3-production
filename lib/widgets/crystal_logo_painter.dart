import 'package:flutter/material.dart';
import 'dart:math' as math;

class CrystalLogoPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  CrystalLogoPainter({
    required this.animationValue,
    this.primaryColor = const Color(0xFF9D4EDD),
    this.secondaryColor = const Color(0xFF7B2CBF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Animated gradient paint
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.8),
          secondaryColor.withOpacity(0.6),
          Colors.transparent,
        ],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw main crystal shape
    final path = Path();
    final points = 6;
    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * math.pi / points) + (animationValue * math.pi / 4);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // Draw inner sparkles
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.8 * animationValue)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi / 8) + (animationValue * math.pi * 2);
      final sparkleRadius = radius * 0.3;
      final x = center.dx + sparkleRadius * math.cos(angle);
      final y = center.dy + sparkleRadius * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 2, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}