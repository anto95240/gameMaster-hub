import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:gamemaster_hub/domain/common/enums.dart';

class PlayerFormData {
  String nom = '';
  int age = 18;
  int niveauActuel = 60;
  int potentiel = 80;
  int montantTransfert = 1000000;
  StatusEnum status = StatusEnum.Titulaire;
  int dureeContrat = 2028;
  int salaire = 10000;
  List<PosteEnum> postesSelectionnes = [];
}

class PlayerFormFields extends StatelessWidget {
  final PlayerFormData formData;
  const PlayerFormFields({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: "Nom"),
          validator: (v) => (v == null || v.isEmpty) ? "Nom obligatoire" : null,
          onSaved: (v) => formData.nom = v!,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(labelText: "Âge"),
          keyboardType: TextInputType.number,
          initialValue: "18",
          validator: (v) {
            final val = int.tryParse(v ?? '');
            if (val == null) return "Doit être un nombre";
            if (val < 16) return "L'âge doit être ≥ 16";
            return null;
          },
          onSaved: (v) => formData.age = int.tryParse(v ?? "18") ?? 18,
        ),
        const SizedBox(height: 8),
        MultiSelectDialogField<PosteEnum>(
          items: PosteEnum.values.map((p) => MultiSelectItem(p, p.name)).toList(),
          title: const Text("Postes"),
          buttonText: const Text("Choisir les postes"),
          onConfirm: (values) => formData.postesSelectionnes = values,
          validator: (values) => (values == null || values.isEmpty)
              ? "Sélectionner au moins un poste"
              : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(labelText: "Niveau actuel"),
          keyboardType: TextInputType.number,
          initialValue: "60",
          validator: (v) {
            final val = int.tryParse(v ?? '');
            if (val == null) return "Doit être un nombre";
            if (val < 0 || val > 100) return "Doit être entre 0 et 100";
            return null;
          },
          onSaved: (v) => formData.niveauActuel = int.tryParse(v ?? "60") ?? 60,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<StatusEnum>(
          value: formData.status,
          decoration: const InputDecoration(labelText: "Statut"),
          items: StatusEnum.values
              .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
              .toList(),
          onChanged: (v) => formData.status = v!,
        ),
      ],
    );
  }
}
