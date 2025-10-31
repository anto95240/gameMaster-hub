import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'player_with_position.dart'; // ✅ pour getPositionColor

class PlayerDetailsDialog extends StatelessWidget {
  final JoueurSm player;
  final PosteEnum poste;

  const PlayerDetailsDialog({
    super.key,
    required this.player,
    required this.poste,
  });

  @override
  Widget build(BuildContext context) {
    final color = getPositionColor(poste.name);

    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(backgroundColor: color, child: Text(poste.name)),
          const SizedBox(width: 12),
          Text(player.nom),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Âge : ${player.age} ans'),
          Text('Niveau actuel : ${player.niveauActuel}'),
          Text('Potentiel : ${player.potentiel}'),
          Text('Postes : ${player.postes.map((e) => e.name).join(', ')}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
