// [lib/presentation/sm/widgets/tactics/football_field.dart]
// (Seule la fonction _getPosteKeysForFormation est modifiée)
import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart'; // Pour JoueursSmState

import 'football_field_painter.dart';
import 'player_info_modal.dart';

class FootballField extends StatelessWidget {
  final String formation;
  final bool isLargeScreen;
  
  // ✅ Ces données viennent du TacticsSmBloc
  final Map<String, JoueurSmWithStats?> assignedPlayersByPoste;
  final Map<int, RoleModeleSm> assignedRolesByPlayerId;
  final JoueursSmState allPlayers; // Vient du JoueursSmBloc

  const FootballField({
    Key? key,
    required this.formation,
    required this.isLargeScreen,
    this.assignedPlayersByPoste = const {},
    this.assignedRolesByPlayerId = const {},
    required this.allPlayers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);

    final constraints = switch (screenType) {
      ScreenType.mobile =>
          const BoxConstraints(maxWidth: 340, maxHeight: 520),
      ScreenType.tablet =>
          const BoxConstraints(maxWidth: 420, maxHeight: 640),
      ScreenType.laptop =>
          const BoxConstraints(maxWidth: 500, maxHeight: 720),
      ScreenType.laptopL =>
          const BoxConstraints(maxWidth: 560, maxHeight: 760),
    };

    return Container(
      constraints: constraints,
      child: AspectRatio(
        aspectRatio: 0.65,
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
              painter: FootballFieldPainter(screenType),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: _getFormationPositions(
                      constraints,
                      formation,
                      screenType,
                      context, // Ajout de context pour le modal
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construit la liste des widgets de joueurs
  List<Widget> _getFormationPositions(
      BoxConstraints constraints, String formation, ScreenType screenType, BuildContext context) {
    
    // 1. Obtenir les positions (x, y)
    // ✅ CORRIGÉ : Les clés correspondent maintenant à _getPosteKeysForFormation
    final formationsXY = {
      '4-3-3': [ [0.5, 0.90], [0.18, 0.70], [0.38, 0.70], [0.62, 0.70], [0.82, 0.70], [0.25, 0.50], [0.5, 0.45], [0.75, 0.50], [0.25, 0.20], [0.75, 0.20], [0.5, 0.15], ], // MOG, MOD, BUC
      '4-4-2': [ [0.5, 0.90], [0.18, 0.70], [0.38, 0.70], [0.62, 0.70], [0.82, 0.70], [0.18, 0.50], [0.38, 0.50], [0.62, 0.50], [0.82, 0.50], [0.38, 0.20], [0.62, 0.20], ],
      '4-3-1-2': [ [0.5, 0.90], [0.18, 0.70], [0.38, 0.70], [0.62, 0.70], [0.82, 0.70], [0.25, 0.50], [0.5, 0.55], [0.75, 0.50], [0.5, 0.35], [0.38, 0.20], [0.62, 0.20], ],
      '4-2-3-1': [ [0.5, 0.90], [0.18, 0.70], [0.38, 0.70], [0.62, 0.70], [0.82, 0.70], [0.35, 0.55], [0.65, 0.55], [0.25, 0.40], [0.5, 0.35], [0.75, 0.40], [0.5, 0.20], ], // MOG, MOC, MOD, BUC
      '4-2-2-2': [ [0.5, 0.90], [0.18, 0.70], [0.38, 0.70], [0.62, 0.70], [0.82, 0.70], [0.35, 0.55], [0.65, 0.55], [0.35, 0.35], [0.65, 0.35], [0.38, 0.20], [0.62, 0.20], ],
      '3-4-3': [ [0.5, 0.90], [0.25, 0.70], [0.5, 0.70], [0.75, 0.70], [0.18, 0.50], [0.38, 0.50], [0.62, 0.50], [0.82, 0.50], [0.25, 0.20], [0.75, 0.20], [0.5, 0.15], ],
      '3-5-2': [ [0.5, 0.90], [0.25, 0.70], [0.5, 0.70], [0.75, 0.70], [0.18, 0.50], [0.5, 0.55], [0.35, 0.40], [0.65, 0.40], [0.82, 0.50], [0.38, 0.20], [0.62, 0.20], ],
      '3-3-3-1': [ [0.5, 0.90], [0.25, 0.70], [0.5, 0.70], [0.75, 0.70], [0.25, 0.55], [0.5, 0.55], [0.75, 0.55], [0.25, 0.35], [0.5, 0.35], [0.75, 0.35], [0.5, 0.15], ],
      '3-2-4-1': [ [0.5, 0.90], [0.25, 0.70], [0.5, 0.70], [0.75, 0.70], [0.35, 0.55], [0.65, 0.55], [0.18, 0.35], [0.38, 0.35], [0.62, 0.35], [0.82, 0.35], [0.5, 0.15], ],
    };

    // 2. Obtenir les clés de poste (G, DC1, DC2...)
    final posteKeys = _getPosteKeysForFormation(formation);
    final positionsXY = formationsXY[formation] ?? formationsXY['4-3-3']!;

    if (positionsXY.length != posteKeys.length) {
      // Sécurité si les maps ne sont pas synchronisées
      return [const Center(child: Text("Erreur de configuration formation"))];
    }

    List<Widget> playerWidgets = [];
    for (int i = 0; i < positionsXY.length; i++) {
      final posXY = positionsXY[i];
      final posteKey = posteKeys[i]; // ex: "DC1"
      final basePoste = posteKey.replaceAll(RegExp(r'[0-9]'), ''); // ex: "DC"

      // 3. Trouver le joueur et le rôle pour ce poste
      final JoueurSmWithStats? player = assignedPlayersByPoste[posteKey];
      final RoleModeleSm? role = (player != null) ? assignedRolesByPlayerId[player.joueur.id] : null;

      playerWidgets.add(
        PlayerPosition(
          constraints: constraints,
          x: posXY[0],
          y: posXY[1],
          screenType: screenType,
          player: player,
          role: role,
          allPlayers: allPlayers,
          basePoste: basePoste,
          buildContext: context, // Passe le context
        ),
      );
    }
    return playerWidgets;
  }
  
  // ✅✅✅ CARTE CANONIQUE DES FORMATIONS ✅✅✅
  // Helper pour mapper les clés de poste
  List<String> _getPosteKeysForFormation(String formation) {
    // Utilise les clés de la base (ex: MOG, BUC) et des numéros pour les doublons
    final map = {
      '4-4-2': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MG', 'MC1', 'MC2', 'MD', 'BUC1', 'BUC2'],
      '4-3-1-2': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MC1', 'MC2', 'MC3', 'MOC', 'BUC1', 'BUC2'],
      '4-2-3-1': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MDC1', 'MDC2', 'MOG', 'MOC', 'MOD', 'BUC'],
      '4-2-2-2': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MDC1', 'MDC2', 'MOC1', 'MOC2', 'BUC1', 'BUC2'],
      '4-3-3': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MC1', 'MC2', 'MC3', 'MOG', 'MOD', 'BUC'],
      '3-4-3': ['G', 'DC1', 'DC2', 'DC3', 'MG', 'MC1', 'MC2', 'MD', 'MOG', 'MOD', 'BUC'],
      '3-5-2': ['G', 'DC1', 'DC2', 'DC3', 'MG', 'MDC', 'MC1', 'MC2', 'MD', 'BUC1', 'BUC2'],
      '3-3-3-1': ['G', 'DC1', 'DC2', 'DC3', 'MDC1', 'MDC2', 'MDC3', 'MOG', 'MOC', 'MOD', 'BUC'],
      '3-2-4-1': ['G', 'DC1', 'DC2', 'DC3', 'MDC1', 'MDC2', 'MOG', 'MOC1', 'MOC2', 'MOD', 'BUC'],
    };
    return map[formation] ?? map['4-3-3']!; // Fallback sur 4-3-3
  }
}

class PlayerPosition extends StatelessWidget {
  final BoxConstraints constraints;
  final double x;
  final double y;
  final ScreenType screenType;

  final JoueurSmWithStats? player;
  final RoleModeleSm? role;
  final JoueursSmState allPlayers;
  final String basePoste;
  final BuildContext buildContext; // Contexte pour le modal

  const PlayerPosition({
    Key? key,
    required this.constraints,
    required this.x,
    required this.y,
    required this.screenType,
    this.player,
    this.role,
    required this.allPlayers,
    required this.basePoste,
    required this.buildContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double size = switch (screenType) {
      ScreenType.mobile => 20,
      ScreenType.tablet => 22,
      ScreenType.laptop => 24,
      ScreenType.laptopL => 26,
    };
    
    final color = player != null ? Colors.amberAccent : Colors.white;

    return Positioned(
      left: constraints.maxWidth * x - (size / 2),
      top: constraints.maxHeight * y - (size / 2),
      child: GestureDetector(
        // Utilise le buildContext passé
        onTap: () => _showPlayerModal(buildContext, player, role, allPlayers, basePoste),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: player != null ?
            Center(
              child: Text(
                player!.joueur.nom.isNotEmpty ? player!.joueur.nom[0] : '?',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.5,
                ),
              ),
            ) : null,
        ),
      ),
    );
  }

  void _showPlayerModal(
    BuildContext context,
    JoueurSmWithStats? player,
    RoleModeleSm? role,
    JoueursSmState allPlayers,
    String basePoste,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) => PlayerInfoModal(
        player: player,
        role: role,
        allPlayers: allPlayers,
        basePoste: basePoste,
      ),
    );
  }
}