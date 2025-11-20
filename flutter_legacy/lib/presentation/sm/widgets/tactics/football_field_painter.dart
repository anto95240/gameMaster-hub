import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';

class FootballFieldPainter extends CustomPainter {
  final ScreenType screenType;
  final ThemeData theme;

  FootballFieldPainter(this.screenType, {required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = switch (screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.2,
      ScreenType.laptop => 1.5,
      ScreenType.laptopL => 1.8,
    };

    final fieldColor = theme.cardColor;
    final stripeColor = theme.dividerColor;
    final lineColor = theme.colorScheme.onSurface.withOpacity(0.3); 

    final paintLine = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = fieldColor,
    );

    final stripePaint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.fill;
    const stripeCount = 10; 
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

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintLine);
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paintLine,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.2, 
      paintLine,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      2.5,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill,
    );
    _drawGoalBox(canvas, paintLine, 0, size);
    _drawGoalBox(canvas, paintLine, size.width, size);
  }

  void _drawGoalBox(Canvas canvas, Paint paint, double x, Size size) {
    final double boxWidth = size.width * 0.17; 
    final double boxHeight = size.height * 0.7;

    if (x == 0) {
      canvas.drawRect(
          Rect.fromLTWH(0, (size.height - boxHeight) / 2, boxWidth, boxHeight),
          paint);
    } else {
      canvas.drawRect(
          Rect.fromLTWH(size.width - boxWidth, (size.height - boxHeight) / 2,
              boxWidth, boxHeight),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant FootballFieldPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.screenType != screenType;
}