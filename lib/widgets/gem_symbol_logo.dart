import 'package:flutter/material.dart';
import 'dart:math' as math;

class GemSymbolLogo extends StatefulWidget {
  final double size;
  final bool animate;
  final List<Color> colors;

  const GemSymbolLogo({
    Key? key,
    this.size = 100,
    this.animate = true,
    this.colors = const [
      Color(0xFF9966CC), // Amethyst purple
      Color(0xFF8A2BE2), // Blue violet
      Color(0xFFDDA0DD), // Plum
    ],
  }) : super(key: key);

  @override
  State<GemSymbolLogo> createState() => _GemSymbolLogoState();
}

class _GemSymbolLogoState extends State<GemSymbolLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.animate ? _pulseAnimation.value : 1.0,
            child: Transform.rotate(
              angle: widget.animate ? _rotationAnimation.value : 0.0,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GemPainter(
                  colors: widget.colors,
                  animationValue: widget.animate ? _pulseAnimation.value : 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GemPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;

  _GemPainter({
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Main gem body
    final gemPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colors[0].withOpacity(0.9),
          colors[1].withOpacity(0.7),
          colors[2].withOpacity(0.5),
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw gem shape (diamond)
    final gemPath = Path();
    // Top point
    gemPath.moveTo(center.dx, center.dy - radius);
    // Top right
    gemPath.lineTo(center.dx + radius * 0.6, center.dy - radius * 0.3);
    // Middle right
    gemPath.lineTo(center.dx + radius * 0.4, center.dy + radius * 0.2);
    // Bottom point
    gemPath.lineTo(center.dx, center.dy + radius);
    // Bottom left
    gemPath.lineTo(center.dx - radius * 0.4, center.dy + radius * 0.2);
    // Top left
    gemPath.lineTo(center.dx - radius * 0.6, center.dy - radius * 0.3);
    gemPath.close();

    canvas.drawPath(gemPath, gemPaint);

    // Draw facet lines
    final facetPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * animationValue)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Vertical center line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      facetPaint,
    );

    // Left facet line
    canvas.drawLine(
      Offset(center.dx - radius * 0.6, center.dy - radius * 0.3),
      Offset(center.dx, center.dy + radius),
      facetPaint,
    );

    // Right facet line
    canvas.drawLine(
      Offset(center.dx + radius * 0.6, center.dy - radius * 0.3),
      Offset(center.dx, center.dy + radius),
      facetPaint,
    );

    // Sparkle highlights
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.8 * animationValue)
      ..style = PaintingStyle.fill;

    // Top sparkle
    canvas.drawCircle(
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.6),
      2 * animationValue,
      sparklePaint,
    );

    // Side sparkle
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.1),
      1.5 * animationValue,
      sparklePaint,
    );

    // Outer glow
    final glowPaint = Paint()
      ..color = colors[0].withOpacity(0.2 * animationValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(gemPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}