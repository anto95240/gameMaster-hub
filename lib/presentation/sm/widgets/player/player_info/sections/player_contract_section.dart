import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';

class PlayerContractSection extends StatelessWidget {
  final JoueurSm joueur;
  final bool isEditing;
  const PlayerContractSection({super.key, required this.joueur, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return TextField(
        decoration: const InputDecoration(
          labelText: 'Durée contrat (années)',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: joueur.dureeContrat.toString()),
      );
    }
    return Text(
      "Contrat jusqu'à ${joueur.dureeContrat}",
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}