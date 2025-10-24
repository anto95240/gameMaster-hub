import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class PlayerContractSection extends StatefulWidget {
  final JoueurSm joueur;
  final bool isEditing;
  final Function(int)? onDurationChanged;
  
  const PlayerContractSection({
    super.key, 
    required this.joueur, 
    required this.isEditing,
    this.onDurationChanged,
  });

  @override
  State<PlayerContractSection> createState() => _PlayerContractSectionState();
}

class _PlayerContractSectionState extends State<PlayerContractSection> {
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(text: widget.joueur.dureeContrat.toString());
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return TextField(
        decoration: const InputDecoration(
          labelText: 'Durée contrat (années)',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        controller: _durationController,
        onChanged: (value) {
          final duration = int.tryParse(value) ?? widget.joueur.dureeContrat;
          widget.onDurationChanged?.call(duration);
        },
      );
    }
    return Text(
      "Contrat jusqu'à ${widget.joueur.dureeContrat}",
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}