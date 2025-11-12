// [lib/presentation/sm/widgets/tactics/football_field_painter.dart]
import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'field_position_mapper.dart'; // Importe le mapper pour les étiquettes

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

    // Couleurs
    final fieldColor = const Color(0xFF388E3C); // Vert principal
    final stripeColor = const Color(0xFF4CAF50); // Vert plus clair
    final lineColor = Colors.white.withOpacity(0.7);
    final zoneLineColor = Colors.black.withOpacity(0.5);
    final labelColor = Colors.white.withOpacity(0.5);

    // Peinture pour les lignes BLANCHES
    final paintWhite = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Peinture pour les lignes NOIRES (zones)
    final paintBlack = Paint()
      ..color = zoneLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.5; // Un peu plus épaisses

    // 1. Fond vert
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = fieldColor,
    );

    // 2. Bandes de pelouse horizontales (mode paysage)
    final stripePaint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.fill;
    const stripeCount = 6; // Moins de bandes car paysage
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

    // 3. Lignes blanches classiques (terrain en paysage)
    // Ligne de touche extérieure
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintWhite);
    // Ligne médiane
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paintWhite,
    );
    // Cercle central
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.2, // Rayon basé sur la hauteur
      paintWhite,
    );
    // Point central
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      2.5,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill,
    );
    // Surface de réparation GAUCHE (Gardien)
    _drawGoalBox(canvas, paintWhite, 0, size);
    // Surface de réparation DROITE (Attaquants)
    _drawGoalBox(canvas, paintWhite, size.width, size);

    // 4. Lignes NOIRES des zones (selon l'image)
    // Lignes verticales
    canvas.drawLine(Offset(size.width * 0.18, 0),
        Offset(size.width * 0.18, size.height), paintBlack);
    canvas.drawLine(Offset(size.width * 0.36, 0),
        Offset(size.width * 0.36, size.height), paintBlack);
    canvas.drawLine(Offset(size.width * 0.64, 0),
        Offset(size.width * 0.64, size.height), paintBlack);
    canvas.drawLine(Offset(size.width * 0.82, 0),
        Offset(size.width * 0.82, size.height), paintBlack);
    // Lignes horizontales
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.25),
        Offset(size.width, size.height * 0.25), paintBlack);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.75),
        Offset(size.width, size.height * 0.75), paintBlack);
    // Ligne centrale pour MDC/MC/MOC (partielle)
    canvas.drawLine(Offset(size.width * 0.36, size.height * 0.5),
        Offset(size.width * 0.64, size.height * 0.5), paintBlack);

    // 5. Étiquettes de postes
    final textStyle = TextStyle(
      color: labelColor,
      fontSize: 14, // Augmentation de la taille
      fontWeight: FontWeight.w900,
    );
    for (var labelInfo in FieldPositionMapper.posteLabels) {
      final double x = size.width * (labelInfo[0] as double);
      final double y = size.height * (labelInfo[1] as double);
      final String label = labelInfo[2] as String;

      final textSpan = TextSpan(text: label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  // Helper pour dessiner les surfaces de réparation
  void _drawGoalBox(Canvas canvas, Paint paint, double x, Size size) {
    // Dimensions en mode paysage
    final double boxWidth = size.width * 0.18; // 18% de la largeur
    final double boxHeight = size.height * 0.5; // 50% de la hauteur
    final double goalWidth = size.width * 0.08;
    final double goalHeight = size.height * 0.25;

    if (x == 0) {
      // Côté gauche (Gardien)
      canvas.drawRect(
          Rect.fromLTWH(0, (size.height - boxHeight) / 2, boxWidth, boxHeight),
          paint);
      canvas.drawRect(
          Rect.fromLTWH(
              0, (size.height - goalHeight) / 2, goalWidth, goalHeight),
          paint);
    } else {
      // Côté droit (Attaquant)
      canvas.drawRect(
          Rect.fromLTWH(
              size.width - boxWidth, (size.height - boxHeight) / 2, boxWidth, boxHeight),
          paint);
      canvas.drawRect(
          Rect.fromLTWH(size.width - goalWidth, (size.height - goalHeight) / 2,
              goalWidth, goalHeight),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}