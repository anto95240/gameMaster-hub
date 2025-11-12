// [lib/presentation/sm/widgets/tactics/football_field_painter.dart]
import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
// Note: field_position_mapper.dart n'est plus importé car les étiquettes sont supprimées.

class FootballFieldPainter extends CustomPainter {
  final ScreenType screenType;

  // Couleurs du Thème Dark (pour l'harmonie)
  static const Color _bgSecondaryDark = Color(0xFF2C2C3A);
  static const Color _borderDark = Color(0xFF2F2F3A);

  FootballFieldPainter(this.screenType);

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = switch (screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.2,
      ScreenType.laptop => 1.5,
      ScreenType.laptopL => 1.8,
    };

    // --- COULEURS HARMONISÉES AVEC LE THÈME DARK ---
    final fieldColor = _bgSecondaryDark;
    final stripeColor = _borderDark; // Bandes très subtiles
    final lineColor = Colors.white.withOpacity(0.3); // Lignes blanches fines

    // Peinture pour les lignes BLANCHES
    final paintWhite = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 1. Fond
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = fieldColor,
    );

    // 2. Bandes de pelouse horizontales
    final stripePaint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.fill;
    const stripeCount = 10; // 10 bandes pour un effet subtil
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

    // 4. Lignes de zone et étiquettes -> SUPPRIMÉES
  }

  // Helper pour dessiner les surfaces de réparation
  void _drawGoalBox(Canvas canvas, Paint paint, double x, Size size) {
    // Dimensions en mode paysage
    final double boxWidth = size.width * 0.17; // 17% de la largeur
    final double boxHeight = size.height * 0.7; // 70% de la hauteur

    if (x == 0) {
      // Côté gauche (Gardien)
      canvas.drawRect(
          Rect.fromLTWH(0, (size.height - boxHeight) / 2, boxWidth, boxHeight),
          paint);
    } else {
      // Côté droit (Attaquant)
      canvas.drawRect(
          Rect.fromLTWH(size.width - boxWidth, (size.height - boxHeight) / 2,
              boxWidth, boxHeight),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}