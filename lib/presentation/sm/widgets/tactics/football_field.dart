// [lib/presentation/sm/widgets/tactics/football_field.dart]
import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

// Imports des widgets
import 'football_field_painter.dart';
import 'player_info_modal.dart';
import 'field_player_card.dart';
import 'field_position_mapper.dart'; // ✅ Utilisation du nouveau mapper

class FootballField extends StatelessWidget {
  final String formation;
  final bool isLargeScreen;

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
    // ✅ 3. Fond du terrain : Récupération du thème
    final theme = Theme.of(context);

    // ✅ MODIFIÉ : Aspect ratio 1.6:1 (plus large, comme l'exemple)
    final double aspectRatio = 1.6;

    // Contraintes
    final constraints = switch (screenType) {
      ScreenType.mobile =>
          const BoxConstraints(maxWidth: 500, maxHeight: 312),
      ScreenType.tablet =>
          const BoxConstraints(maxWidth: 700, maxHeight: 437),
      ScreenType.laptop =>
          const BoxConstraints(maxWidth: 800, maxHeight: 500),
      ScreenType.laptopL =>
          const BoxConstraints(maxWidth: 900, maxHeight: 562),
    };

    return Container(
      constraints: constraints,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            // ✅ 3. Fond du terrain : Utilisation de la couleur du thème
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              // ✅ 3. Fond du terrain : Thème passé au painter
              painter: FootballFieldPainter(screenType, theme: theme),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: _buildPlayerWidgets(
                      constraints,
                      formation,
                      context,
                      screenType, // ✅ 1. Texte réactif : screenType passé ici
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

  /// Construit la liste des widgets de joueurs positionnés
  List<Widget> _buildPlayerWidgets(
    BoxConstraints constraints,
    String formation,
    BuildContext context,
    ScreenType screenType, // ✅ 1. Texte réactif : Réception de screenType
  ) {
    final List<Widget> playerWidgets = [];

    // 1. Obtenir les clés de poste (G, DC1, DC2...)
    final posteKeys = _getPosteKeysForFormation(formation);

    // 2. Obtenir le mappage de position [x, y] pour cette formation
    final positionMapping = FieldPositionMapper.getFormationPositions(formation);

    // 3. Dimensions des cartes de joueur
    // ✅ MODIFIÉ : 14% de la largeur
    // final double cardWidth = constraints.maxWidth * 0.14;

    final double cardWidth = switch (screenType) {
      ScreenType.mobile   => constraints.maxWidth * 0.17, // Augmenté à 17%
      ScreenType.tablet   => constraints.maxWidth * 0.15, // Augmenté à 15%
      _                   => constraints.maxWidth * 0.14, // 14% pour laptop/desktop
    };

    for (final posteKey in posteKeys) {
      // 4. Trouver le joueur et le rôle pour ce poste (ex: "DC1")
      final JoueurSmWithStats? player = assignedPlayersByPoste[posteKey];
      final RoleModeleSm? role = (player != null)
          ? assignedRolesByPlayerId[player.joueur.id]
          : null;

      // 5. Trouver la position [x, y] pour ce poste
      final Offset? pos = positionMapping[posteKey];

      if (pos != null && player != null && role != null) {
        playerWidgets.add(
          Positioned(
            // Calcule le coin supérieur gauche pour centrer la carte
            left: (constraints.maxWidth * pos.dx) - (cardWidth / 2),
            
            // ✅ MODIFIÉ : 'top' est ajusté pour centrer verticalement
            // en se basant sur une hauteur de carte approximative (50px)
            top: (constraints.maxHeight * pos.dy) - 28, // 28 ~ 56px / 2
            
            width: cardWidth,

            // ✅ MODIFIÉ : La hauteur fixe (height) a été SUPPRIMÉE.
            // La carte gère sa propre hauteur.
            
            child: FieldPlayerCard(
              player: player,
              role: role,
              // ✅ 1. Texte réactif : screenType passé à la carte
              screenType: screenType,
              onTap: () {
                _showPlayerModal(
                    context, player, role, allPlayers, role.poste);
              },
            ),
          ),
        );
      }
    }
    return playerWidgets;
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

  // ✅✅✅ CARTE CANONIQUE DES FORMATIONS ✅✅✅
  // Cette fonction DOIT être identique à celle dans tactics_bloc.dart
  List<String> _getPosteKeysForFormation(String formation) {
    final map = {
      '4-4-2': [
        'G',
        'DG',
        'DC1',
        'DC2',
        'DD',
        'MG',
        'MC1',
        'MC2',
        'MD',
        'BUC1',
        'BUC2'
      ],
      '4-3-1-2': [
        'G',
        'DG',
        'DC1',
        'DC2',
        'DD',
        'MC1',
        'MC2',
        'MC3',
        'MOC',
        'BUC1',
        'BUC2'
      ],
      '4-2-3-1': [
        'G',
        'DG',
        'DC1',
        'DC2',
        'DD',
        'MDC1',
        'MDC2',
        'MOG',
        'MOC',
        'MOD',
        'BUC'
      ],
      '4-2-2-2': [
        'G',
        'DG',
        'DC1',
        'DC2',
        'DD',
        'MDC1',
        'MDC2',
        'MOC1',
        'MOC2',
        'BUC1',
        'BUC2'
      ],
      '4-3-3': [
        'G',
        'DG',
        'DC1',
        'DC2',
        'DD',
        'MC1',
        'MC2',
        'MC3',
        'MOG',
        'MOD',
        'BUC'
      ],
      '3-4-3': [
        'G',
        'DC1',
        'DC2',
        'DC3',
        'MG',
        'MC1',
        'MC2',
        'MD',
        'MOG',
        'MOD',
        'BUC'
      ],
      '3-5-2': [
        'G',
        'DC1',
        'DC2',
        'DC3',
        'MG',
        'MDC',
        'MC1',
        'MC2',
        'MD',
        'BUC1',
        'BUC2'
      ],
      '3-3-3-1': [
        'G',
        'DC1',
        'DC2',
        'DC3',
        'MDC1',
        'MDC2',
        'MDC3',
        'MOG',
        'MOC',
        'MOD',
        'BUC'
      ],
      '3-2-4-1': [
        'G',
        'DC1',
        'DC2',
        'DC3',
        'MDC1',
        'MDC2',
        'MOG',
        'MOC1',
        'MOC2',
        'MOD',
        'BUC'
      ],
    };
    return map[formation] ?? map['4-3-3']!; // Fallback sur 4-3-3
  }
}