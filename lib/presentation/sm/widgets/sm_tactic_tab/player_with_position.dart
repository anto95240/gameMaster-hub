import 'package:flutter/material.dart';

/// Modèle léger utilisé par l’UI tactique,
/// construit à partir de `joueur_sm` et `stats_joueur_sm`.
class TacticPlayer {
  final int id;
  final String name;            // joueur_sm.nom
  final int? age;               // joueur_sm.age
  final int overall;            // joueur_sm.niveau_actuel
  final String? preferredPosition; // 1er poste de joueur_sm.postes[]
  // Stats mappées depuis stats_joueur_sm
  final int? pace;       // stats.vitesse
  final int? shooting;   // stats.finition
  final int? passing;    // stats.passes
  final int? dribbling;  // stats.dribble
  final int? defending;  // moyenne tacles/positionnement si dispo
  final int? physical;   // stats.force

  const TacticPlayer({
    required this.id,
    required this.name,
    required this.overall,
    this.age,
    this.preferredPosition,
    this.pace,
    this.shooting,
    this.passing,
    this.dribbling,
    this.defending,
    this.physical,
  });
}

/// Joueur positionné sur le terrain par l’algorithme.
class PlayerWithPosition {
  final TacticPlayer player;
  final String position;       // ex: 'LCB', 'ST', ...
  final double compatibility;  // score 0-100

  const PlayerWithPosition({
    required this.player,
    required this.position,
    this.compatibility = 0.0,
  });

  PlayerWithPosition copyWith({
    TacticPlayer? player,
    String? position,
    double? compatibility,
  }) {
    return PlayerWithPosition(
      player: player ?? this.player,
      position: position ?? this.position,
      compatibility: compatibility ?? this.compatibility,
    );
  }
}

/// Couleur par famille de postes
Color getPositionColor(String position) {
  if (position == 'GK') return Colors.yellow[700]!;
  if (['LB', 'LCB', 'CB', 'RCB', 'RB', 'LWB', 'RWB'].contains(position)) {
    return Colors.blue[700]!;
  }
  if ([
    'LDM','CDM','RDM','LCM','CM','RCM','LM','RM','LAM','CAM','RAM'
  ].contains(position)) {
    return Colors.green[700]!;
  }
  if (['LW','LF','CF','ST','RF','RW'].contains(position)) {
    return Colors.red[700]!;
  }
  return Colors.grey[700]!;
}
