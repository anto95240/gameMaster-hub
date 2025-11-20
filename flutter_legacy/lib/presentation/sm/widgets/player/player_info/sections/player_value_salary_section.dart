import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class PlayerValueSalarySection extends StatefulWidget {
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
  State<PlayerValueSalarySection> createState() => _PlayerValueSalarySectionState();
}

class _PlayerValueSalarySectionState extends State<PlayerValueSalarySection> {
  late TextEditingController _valueController;
  late TextEditingController _salaryController;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.joueur.montantTransfert.toString());
    _salaryController = TextEditingController(text: widget.joueur.salaire.toString());
  }

  @override
  void dispose() {
    _valueController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Valeur & Salaire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!widget.isEditing) ...[
          Text('Valeur marchande : ${widget.joueur.montantTransfert} €'),
          Text('Salaire : ${widget.joueur.salaire} €/an'),
        ] else ...[
          TextField(
            decoration: const InputDecoration(labelText: 'Valeur marchande (€)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            controller: _valueController,
            onChanged: (_) => widget.onChanged(
              int.tryParse(_valueController.text) ?? widget.joueur.montantTransfert,
              int.tryParse(_salaryController.text) ?? widget.joueur.salaire,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Salaire (€ / an)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            controller: _salaryController,
            onChanged: (_) => widget.onChanged(
              int.tryParse(_valueController.text) ?? widget.joueur.montantTransfert,
              int.tryParse(_salaryController.text) ?? widget.joueur.salaire,
            ),
          ),
        ]
      ],
    );
  }
}