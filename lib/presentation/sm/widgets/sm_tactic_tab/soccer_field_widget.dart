import 'package:flutter/material.dart';

/// CustomPainter pour dessiner un terrain de football réaliste
class SoccerFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2D5016); // Vert gazon foncé

    // Fond du terrain (gazon)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      fillPaint,
    );

    // Bandes de gazon alternées pour effet réaliste
    _drawGrassStripes(canvas, size);

    // Bordure du terrain
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Ligne médiane
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Cercle central
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final centerCircleRadius = size.width * 0.15;
    
    canvas.drawCircle(
      Offset(centerX, centerY),
      centerCircleRadius,
      paint,
    );

    // Point central
    canvas.drawCircle(
      Offset(centerX, centerY),
      3,
      Paint()..color = Colors.white,
    );

    // Surface de réparation supérieure (équipe adverse)
    final penaltyBoxWidth = size.width * 0.6;
    final penaltyBoxHeight = size.height * 0.15;
    
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        0,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      paint,
    );

    // Surface de but supérieure
    final goalBoxWidth = size.width * 0.3;
    final goalBoxHeight = size.height * 0.08;
    
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalBoxWidth) / 2,
        0,
        goalBoxWidth,
        goalBoxHeight,
      ),
      paint,
    );

    // Point de penalty supérieur
    canvas.drawCircle(
      Offset(centerX, penaltyBoxHeight * 0.6),
      3,
      Paint()..color = Colors.white,
    );

    // Surface de réparation inférieure (notre équipe)
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        size.height - penaltyBoxHeight,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      paint,
    );

    // Surface de but inférieure
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalBoxWidth) / 2,
        size.height - goalBoxHeight,
        goalBoxWidth,
        goalBoxHeight,
      ),
      paint,
    );

    // Point de penalty inférieur
    canvas.drawCircle(
      Offset(centerX, size.height - (penaltyBoxHeight * 0.6)),
      3,
      Paint()..color = Colors.white,
    );

    // Buts
    _drawGoal(canvas, size, true); // But supérieur
    _drawGoal(canvas, size, false); // But inférieur
  }

  void _drawGrassStripes(Canvas canvas, Size size) {
    final stripePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF3A6B1F); // Vert gazon clair

    const stripeCount = 10;
    final stripeHeight = size.height / stripeCount;

    for (int i = 0; i < stripeCount; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        stripePaint,
      );
    }
  }

  void _drawGoal(Canvas canvas, Size size, bool isTop) {
    final goalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.white;

    final goalWidth = size.width * 0.2;
    final goalDepth = 10.0;
    final goalX = (size.width - goalWidth) / 2;
    final goalY = isTop ? -goalDepth : size.height;

    // Poteau gauche
    canvas.drawLine(
      Offset(goalX, goalY),
      Offset(goalX, goalY + (isTop ? goalDepth : -goalDepth)),
      goalPaint,
    );

    // Barre transversale
    canvas.drawLine(
      Offset(goalX, goalY + (isTop ? goalDepth : -goalDepth)),
      Offset(goalX + goalWidth, goalY + (isTop ? goalDepth : -goalDepth)),
      goalPaint,
    );

    // Poteau droit
    canvas.drawLine(
      Offset(goalX + goalWidth, goalY),
      Offset(goalX + goalWidth, goalY + (isTop ? goalDepth : -goalDepth)),
      goalPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
