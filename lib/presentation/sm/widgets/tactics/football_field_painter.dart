import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';

class FootballFieldPainter extends CustomPainter {
  final ScreenType screenType;

  FootballFieldPainter(this.screenType);

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = switch (screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.2,
      ScreenType.laptop => 1.5,
      ScreenType.laptopL => 1.8,
    };

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Rectangle extérieur du terrain
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Ligne médiane
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Cercle central (ajusté selon largeur)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.12,
      paint,
    );

    // Point central
    final pointPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 2.5, pointPaint);

    // 🥅 Surface de réparation BAS
    _drawBox(
      canvas,
      paint,
      x: size.width * 0.22,
      y: size.height * 0.82,
      w: size.width * 0.56,
      h: size.height * 0.18,
    );

    // Petite surface BAS
    _drawBox(
      canvas,
      paint,
      x: size.width * 0.36,
      y: size.height * 0.935,
      w: size.width * 0.28,
      h: size.height * 0.065,
    );

    // 🥅 Surface de réparation HAUT
    _drawBox(
      canvas,
      paint,
      x: size.width * 0.22,
      y: 0,
      w: size.width * 0.56,
      h: size.height * 0.18,
    );

    // Petite surface HAUT
    _drawBox(
      canvas,
      paint,
      x: size.width * 0.36,
      y: 0,
      w: size.width * 0.28,
      h: size.height * 0.065,
    );

    // Bandes de pelouse horizontales (adaptées à la hauteur)
    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final stripeCount = switch (screenType) {
      ScreenType.mobile => 10,
      ScreenType.tablet => 12,
      ScreenType.laptop => 14,
      ScreenType.laptopL => 16,
    };

    for (int i = 0; i < stripeCount; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            0,
            i * (size.height / stripeCount),
            size.width,
            size.height / stripeCount,
          ),
          stripePaint,
        );
      }
    }
  }

  void _drawBox(Canvas canvas, Paint paint,
      {required double x, required double y, required double w, required double h}) {
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
