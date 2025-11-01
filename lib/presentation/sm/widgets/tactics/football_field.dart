import 'package:flutter/material.dart';

import 'football_field_painter.dart';
import 'player_info_modal.dart';

class FootballField extends StatelessWidget {
  final String formation;
  final bool isLargeScreen;

  const FootballField({
    Key? key,
    required this.formation,
    required this.isLargeScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = isLargeScreen ? 700.0 : 600.0;
    final maxHeight = isLargeScreen ? 480.0 : 420.0;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      child: AspectRatio(
        aspectRatio: 1.45,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9ccc65),
                Color(0xFF8bc34a),
                Color(0xFF7cb342),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              painter: FootballFieldPainter(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: _getFormationPositions(constraints, formation),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getFormationPositions(BoxConstraints constraints, String formation) {
    // Positions selon la formation
    Map<String, List<List<double>>> formations = {
      '4-3-3': [
        [0.12, 0.5], // GK
        [0.28, 0.18], [0.28, 0.40], [0.28, 0.60], [0.28, 0.82], // DEF
        [0.50, 0.30], [0.50, 0.50], [0.50, 0.70], // MID
        [0.75, 0.25], [0.75, 0.50], [0.75, 0.75], // ATT
      ],
      '4-4-2': [
        [0.12, 0.5], // GK
        [0.28, 0.18], [0.28, 0.40], [0.28, 0.60], [0.28, 0.82], // DEF
        [0.50, 0.20], [0.50, 0.40], [0.50, 0.60], [0.50, 0.80], // MID
        [0.75, 0.35], [0.75, 0.65], // ATT
      ],
      '3-5-2': [
        [0.12, 0.5], // GK
        [0.28, 0.25], [0.28, 0.50], [0.28, 0.75], // DEF
        [0.50, 0.15], [0.50, 0.35], [0.50, 0.50], [0.50, 0.65], [0.50, 0.85], // MID
        [0.75, 0.35], [0.75, 0.65], // ATT
      ],
      '4-2-3-1': [
        [0.12, 0.5], // GK
        [0.28, 0.18], [0.28, 0.40], [0.28, 0.60], [0.28, 0.82], // DEF
        [0.45, 0.35], [0.45, 0.65], // MID DEF
        [0.60, 0.25], [0.60, 0.50], [0.60, 0.75], // MID ATT
        [0.75, 0.50], // ATT
      ],
      '5-3-2': [
        [0.12, 0.5], // GK
        [0.28, 0.12], [0.28, 0.30], [0.28, 0.50], [0.28, 0.70], [0.28, 0.88], // DEF
        [0.50, 0.30], [0.50, 0.50], [0.50, 0.70], // MID
        [0.75, 0.35], [0.75, 0.65], // ATT
      ],
    };

    List<List<double>> positions = formations[formation] ?? formations['4-3-3']!;

    return positions.map((pos) {
      return PlayerPosition(
        constraints: constraints,
        x: pos[0],
        y: pos[1],
      );
    }).toList();
  }
}

class PlayerPosition extends StatelessWidget {
  final BoxConstraints constraints;
  final double x;
  final double y;

  const PlayerPosition({
    Key? key,
    required this.constraints,
    required this.x,
    required this.y,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: constraints.maxWidth * x - 12,
      top: constraints.maxHeight * y - 12,
      child: GestureDetector(
        onTap: () => _showPlayerModal(context),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlayerModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const PlayerInfoModal(),
    );
  }
}