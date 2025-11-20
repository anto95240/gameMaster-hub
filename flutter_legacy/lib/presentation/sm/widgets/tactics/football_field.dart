import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

import 'football_field_painter.dart';
import 'player_info_modal.dart';
import 'field_player_card.dart';
import 'field_position_mapper.dart'; 

class FootballField extends StatelessWidget {
  final String formation;
  final bool isLargeScreen;

  final Map<String, JoueurSmWithStats?> assignedPlayersByPoste;
  final Map<int, RoleModeleSm> assignedRolesByPlayerId;
  final JoueursSmState allPlayers; 
  
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
    final theme = Theme.of(context);

    final double aspectRatio = 1.6;

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
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: FootballFieldPainter(screenType, theme: theme),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: _buildPlayerWidgets(
                      constraints,
                      formation,
                      context,
                      screenType, 
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

  List<Widget> _buildPlayerWidgets(
    BoxConstraints constraints,
    String formation,
    BuildContext context,
    ScreenType screenType,
  ) {
    final List<Widget> playerWidgets = [];

    final posteKeys = _getPosteKeysForFormation(formation);

    final positionMapping = FieldPositionMapper.getFormationPositions(formation);

    final double cardWidth = switch (screenType) {
      ScreenType.mobile   => constraints.maxWidth * 0.17, 
      ScreenType.tablet   => constraints.maxWidth * 0.15, 
      _                   => constraints.maxWidth * 0.14, 
    };

    for (final posteKey in posteKeys) {
      final JoueurSmWithStats? player = assignedPlayersByPoste[posteKey];
      final RoleModeleSm? role = (player != null)
          ? assignedRolesByPlayerId[player.joueur.id]
          : null;

      final Offset? pos = positionMapping[posteKey];

      if (pos != null && player != null && role != null) {
        playerWidgets.add(
          Positioned(
            left: (constraints.maxWidth * pos.dx) - (cardWidth / 2),
            
            top: (constraints.maxHeight * pos.dy) - 28,
            
            width: cardWidth,
            
            child: FieldPlayerCard(
              player: player,
              role: role,
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
    return map[formation] ?? map['4-3-3']!;
  }
}