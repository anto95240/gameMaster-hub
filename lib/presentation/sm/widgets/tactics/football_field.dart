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
    final maxWidth = isLargeScreen ? 500.0 : 400.0;
    final maxHeight = isLargeScreen ? 700.0 : 600.0;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      child: AspectRatio(
        aspectRatio: 0.65, // ✅ Format vertical
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF9ccc65),
                Color(0xFF8bc34a),
                Color(0xFF7cb342),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
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

  /// ✅ Adaptation des positions pour un terrain vertical (haut ↔ bas)
  List<Widget> _getFormationPositions(BoxConstraints constraints, String formation) {
    // Chaque position est exprimée en pourcentage (x = horizontal, y = vertical)
    // y = 1.0 correspond au bas du terrain (gardien), y = 0.0 au haut (attaquants)
    final formations = {
      '4-3-3': [
        [0.5, 0.90], // GK tout en bas
        [0.18, 0.70], [0.38, 0.70], [0.62, 0.70], [0.82, 0.70], // DEF
        [0.25, 0.50], [0.5, 0.45], [0.75, 0.50], // MID
        [0.25, 0.20], [0.5, 0.15], [0.75, 0.20], // ATT
      ],
      '4-4-2': [
        [0.5, 0.90],
        [0.18, 0.70], [0.38, 0.70], [0.62, 0.70], [0.82, 0.70], // DEF
        [0.18, 0.50], [0.38, 0.50], [0.62, 0.50], [0.82, 0.50], // MID
        [0.38, 0.20], [0.62, 0.20], // ATT
      ],
      '3-5-2': [
        [0.5, 0.90],
        [0.3, 0.70], [0.5, 0.70], [0.7, 0.70], // DEF
        [0.18, 0.50], [0.35, 0.45], [0.5, 0.40], [0.65, 0.45], [0.82, 0.50], // MID
        [0.4, 0.20], [0.6, 0.20], // ATT
      ],
      '4-2-3-1': [
        [0.5, 0.90],
        [0.18, 0.70], [0.38, 0.70], [0.62, 0.70], [0.82, 0.70], // DEF
        [0.35, 0.55], [0.65, 0.55], // MID DEF
        [0.25, 0.40], [0.5, 0.35], [0.75, 0.40], // MID ATT
        [0.5, 0.20], // ATT
      ],
      '5-3-2': [
        [0.5, 0.90],
        [0.12, 0.70], [0.3, 0.70], [0.5, 0.70], [0.7, 0.70], [0.88, 0.70], // DEF
        [0.3, 0.50], [0.5, 0.45], [0.7, 0.50], // MID
        [0.4, 0.20], [0.6, 0.20], // ATT
      ],
    };

    final positions = formations[formation] ?? formations['4-3-3']!;

    return positions.map((pos) {
      final x = pos[0];
      final y = pos[1];
      return PlayerPosition(
        constraints: constraints,
        x: x,
        y: y,
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
          width: 26,
          height: 26,
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
