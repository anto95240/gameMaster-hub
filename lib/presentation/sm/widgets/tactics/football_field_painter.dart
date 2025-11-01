import 'package:flutter/material.dart';

class FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Rectangle extérieur du terrain (bords)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Ligne médiane horizontale
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Cercle central
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.12, // adapté à la largeur car le terrain est vertical
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

    // 🥅 Surface de réparation BAS
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.22, // centré
        size.height * 0.82, // en bas
        size.width * 0.56,
        size.height * 0.18,
      ),
      paint,
    );

    // Petite surface BAS
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.36,
        size.height * 0.935,
        size.width * 0.28,
        size.height * 0.065,
      ),
      paint,
    );

    // 🥅 Surface de réparation HAUT
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.22,
        0,
        size.width * 0.56,
        size.height * 0.18,
      ),
      paint,
    );

    // Petite surface HAUT
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.36,
        0,
        size.width * 0.28,
        size.height * 0.065,
      ),
      paint,
    );

    // Bandes de pelouse verticales
    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    const stripeCount = 12; // nombre de bandes
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
