import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:gamemaster_hub/domain/common/enums.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_utils.dart';

class PlayerInfoForm extends StatefulWidget {
  final JoueurSmWithStats item;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;

  const PlayerInfoForm({
    super.key,
    required this.item,
    required this.isEditing,
    required this.onEditingChanged,
  });

  @override
  State<PlayerInfoForm> createState() => _PlayerInfoFormState();
}

class _PlayerInfoFormState extends State<PlayerInfoForm> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController ratingController;
  late TextEditingController potentielController;
  late TextEditingController valueController;
  late TextEditingController dureeContratController;
  late TextEditingController salaireController;
  late String selectedStatus;
  late List<PosteEnum> selectedPostes;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final joueur = widget.item.joueur;
    nameController = TextEditingController(text: joueur.nom);
    ageController = TextEditingController(text: joueur.age.toString());
    ratingController = TextEditingController(text: joueur.niveauActuel.toString());
    potentielController = TextEditingController(text: joueur.potentiel.toString());
    valueController = TextEditingController(text: joueur.montantTransfert.toString());
    dureeContratController = TextEditingController(text: joueur.dureeContrat.toString());
    salaireController = TextEditingController(text: joueur.salaire.toString());
    selectedStatus = joueur.status.name;
    selectedPostes = joueur.postes;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    ratingController.dispose();
    potentielController.dispose();
    valueController.dispose();
    dureeContratController.dispose();
    salaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joueur = widget.item.joueur;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: widget.isEditing
                    ? TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Text(joueur.nom, style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEditableFields(context, joueur),
        ],
      ),
    );
  }

  Widget _buildEditableFields(BuildContext context, JoueurSm joueur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isEditing)
          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Statut',
              border: OutlineInputBorder(),
            ),
            items: StatusEnum.values
                .map((s) => DropdownMenuItem(value: s.name, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => selectedStatus = v!),
          )
        else
          Text(joueur.status.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            if (widget.isEditing)
              Expanded(
                child: MultiSelectDialogField<PosteEnum>(
                  items: PosteEnum.values
                      .map((p) => MultiSelectItem<PosteEnum>(p, p.name))
                      .toList(),
                  initialValue: selectedPostes,
                  title: const Text('Postes'),
                  buttonText: Text(selectedPostes.map((e) => e.name).join('/')),
                  onConfirm: (values) => setState(() => selectedPostes = values),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getPositionColor(joueur.postes.first.name).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  joueur.postes.map((e) => e.name).join('/'),
                  style: TextStyle(
                      color: getPositionColor(joueur.postes.first.name),
                      fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 12),
            if (widget.isEditing)
              SizedBox(
                width: 80,
                child: TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Âge',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            else
              Text('${joueur.age} ans'),
          ],
        ),
      ],
    );
  }
}
