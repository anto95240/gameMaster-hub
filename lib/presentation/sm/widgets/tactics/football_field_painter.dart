import 'package:flutter/material.dart';

class FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Rectangle extérieur
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Ligne médiane
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Cercle central
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.12,
      paint,
    );

    // Point central
    final pointPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      2.5,
      pointPaint,
    );

    // Surface de réparation gauche
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.22, size.width * 0.18, size.height * 0.56),
      paint,
    );

    // Petite surface gauche
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.36, size.width * 0.065, size.height * 0.28),
      paint,
    );

    // Surface de réparation droite
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.82, size.height * 0.22, size.width * 0.18, size.height * 0.56),
      paint,
    );

    // Petite surface droite
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.935, size.height * 0.36, size.width * 0.065, size.height * 0.28),
      paint,
    );

    // Bandes de pelouse
    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 14; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            i * (size.width / 14),
            0,
            size.width / 14,
            size.height,
          ),
          stripePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}