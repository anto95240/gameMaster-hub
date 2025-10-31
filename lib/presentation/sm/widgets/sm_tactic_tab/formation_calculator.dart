import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_tactic_tab/player_with_position.dart';

class FormationCalculator {
  static List<PlayerWithPosition> calculatePositions({
    required String formation,
    required List<JoueurSm> players,
  }) {
    final positions = <PlayerWithPosition>[];

    final formationParts = formation.split('-').map(int.parse).toList();
    if (formationParts.isEmpty) return positions;

    int playerIndex = 0;

    // Gardien
    if (players.isNotEmpty) {
      final gk = players.firstWhere(
        (p) => p.postes.contains(PosteEnum.GK),
        orElse: () => players.first,
      );
      positions.add(
        PlayerWithPosition(
          player: TacticPlayer(
            id: gk.id,
            name: gk.nom,
            overall: gk.niveauActuel,
            age: gk.age,
            preferredPosition: 'GK',
          ),
          position: 'GK',
          compatibility: 100,
        ),
      );
      playerIndex++;
    }

    double currentY = 0.8;
    final yStep = 0.6 / (formationParts.length + 1);

    for (final count in formationParts) {
      final xPositions = _calculateXPositions(count);
      for (final x in xPositions) {
        if (playerIndex >= players.length) break;
        final player = players[playerIndex];
        positions.add(
          PlayerWithPosition(
            player: TacticPlayer(
              id: player.id,
              name: player.nom,
              overall: player.niveauActuel,
              age: player.age,
              preferredPosition:
                  player.postes.isNotEmpty ? player.postes.first.name : 'MC',
            ),
            position: player.postes.isNotEmpty
                ? player.postes.first.name
                : 'MC',
            compatibility: 100,
          ),
        );
        playerIndex++;
      }
      currentY -= yStep;
    }

    return positions;
  }

  static List<double> _calculateXPositions(int count) {
    if (count == 1) return [0.5];
    final positions = <double>[];
    final spacing = 0.7 / (count - 1);
    for (int i = 0; i < count; i++) {
      positions.add(0.15 + spacing * i);
    }
    return positions;
  }

  static const Map<String, String> popularFormations = {
    '4-4-2': 'Formation équilibrée classique',
    '4-3-3': 'Formation offensive avec ailiers',
    '3-5-2': 'Formation dense au milieu',
    '4-2-3-1': 'Formation moderne équilibrée',
  };
}
