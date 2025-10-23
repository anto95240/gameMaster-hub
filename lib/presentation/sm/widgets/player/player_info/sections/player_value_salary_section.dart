import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';

class PlayerValueSalarySection extends StatelessWidget {
  final JoueurSm joueur;
  final bool isEditing;
  final Function(int value, int salary) onChanged;

  const PlayerValueSalarySection({
    super.key,
    required this.joueur,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final valueController = TextEditingController(text: joueur.montantTransfert.toString());
    final salaryController = TextEditingController(text: joueur.salaire.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Valeur & Salaire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!isEditing) ...[
          Text('Valeur marchande : ${joueur.montantTransfert} €'),
          Text('Salaire : ${joueur.salaire} €/an'),
        ] else ...[
          TextField(
            decoration: const InputDecoration(labelText: 'Valeur marchande (€)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            controller: valueController,
            onChanged: (_) => onChanged(
              int.tryParse(valueController.text) ?? joueur.montantTransfert,
              int.tryParse(salaryController.text) ?? joueur.salaire,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Salaire (€ / an)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            controller: salaryController,
            onChanged: (_) => onChanged(
              int.tryParse(valueController.text) ?? joueur.montantTransfert,
              int.tryParse(salaryController.text) ?? joueur.salaire,
            ),
          ),
        ]
      ],
    );
  }
}