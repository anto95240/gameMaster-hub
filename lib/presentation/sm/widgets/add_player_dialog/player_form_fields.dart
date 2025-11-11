import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

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

class PlayerFormFields extends StatefulWidget {
  final PlayerFormData formData;

  const PlayerFormFields({
    super.key,
    required this.formData,
  });

  @override
  State<PlayerFormFields> createState() => _PlayerFormFieldsState();
}

class _PlayerFormFieldsState extends State<PlayerFormFields> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration fieldDecoration(String label) => InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primaryColor),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- NOM ----
        TextFormField(
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: fieldDecoration("Nom"),
          validator: (v) => (v == null || v.isEmpty) ? "Nom obligatoire" : null,
          onSaved: (v) => widget.formData.nom = v!,
        ),
        const SizedBox(height: 12),

        // ---- ÂGE ----
        TextFormField(
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: fieldDecoration("Âge"),
          keyboardType: TextInputType.number,
          initialValue: widget.formData.age.toString(),
          validator: (v) {
            final val = int.tryParse(v ?? '');
            if (val == null) return "Doit être un nombre";
            if (val < 16) return "L'âge doit être ≥ 16";
            return null;
          },
          onSaved: (v) =>
              widget.formData.age = int.tryParse(v ?? "18") ?? 18,
        ),
        const SizedBox(height: 12),

        // ---- POSTES ----
        Text(
          "Postes",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        if (widget.formData.postesSelectionnes.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.4),
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.formData.postesSelectionnes.map((poste) {
                    return Chip(
                      backgroundColor: theme.primaryColor,
                      label: Text(
                        poste.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      deleteIcon:
                          const Icon(Icons.close, color: Colors.white, size: 18),
                      onDeleted: () {
                        setState(() {
                          widget.formData.postesSelectionnes.remove(poste);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

        Divider(
          color: theme.dividerColor.withOpacity(0.6),
          thickness: 1,
        ),
        const SizedBox(height: 12),

        Text(
          "Sélectionner des postes :",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PosteEnum.values.map((poste) {
            final isSelected =
                widget.formData.postesSelectionnes.contains(poste);
            return FilterChip(
              label: Text(poste.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    widget.formData.postesSelectionnes.add(poste);
                  } else {
                    widget.formData.postesSelectionnes.remove(poste);
                  }
                });
              },
              selectedColor: theme.primaryColor.withOpacity(0.2),
              checkmarkColor: theme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? theme.primaryColor : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            );
          }).toList(),
        ),

        if (widget.formData.postesSelectionnes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "⚠️ Sélectionner au moins un poste",
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        const SizedBox(height: 16),

        // ---- Niveau actuel ----
        TextFormField(
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: fieldDecoration("Niveau actuel"),
          keyboardType: TextInputType.number,
          initialValue: widget.formData.niveauActuel.toString(),
          validator: (v) {
            final val = int.tryParse(v ?? '');
            if (val == null) return "Doit être un nombre";
            if (val < 0 || val > 100) return "Doit être entre 0 et 100";
            return null;
          },
          onSaved: (v) =>
              widget.formData.niveauActuel = int.tryParse(v ?? "60") ?? 60,
        ),
        const SizedBox(height: 12),

        // ---- Statut ----
        DropdownButtonFormField<StatusEnum>(
          value: widget.formData.status,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: fieldDecoration("Statut"),
          items: StatusEnum.values
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s.name,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => widget.formData.status = v!,
        ),
        const SizedBox(height: 12),

        // ---- Potentiel ----
        TextFormField(
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: fieldDecoration("Potentiel"),
          keyboardType: TextInputType.number,
          initialValue: widget.formData.potentiel.toString(),
          validator: (v) {
            final val = int.tryParse(v ?? '');
            if (val == null) return "Doit être un nombre";
            if (val < 0 || val > 100) return "Doit être entre 0 et 100";
            return null;
          },
          onSaved: (v) =>
              widget.formData.potentiel = int.tryParse(v ?? "80") ?? 80,
        ),
        const SizedBox(height: 12),

        // ---- Valeur de transfert ----
        TextFormField(
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: fieldDecoration("Valeur de transfert (€)"),
          keyboardType: TextInputType.number,
          initialValue: widget.formData.montantTransfert.toString(),
          onSaved: (v) =>
              widget.formData.montantTransfert = int.tryParse(v ?? "1000000") ?? 1000000,
        ),
        const SizedBox(height: 12),

        // ---- Fin de contrat ----
        TextFormField(
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: fieldDecoration("Fin de contrat (Année)"),
          keyboardType: TextInputType.number,
          initialValue: widget.formData.dureeContrat.toString(),
          onSaved: (v) =>
              widget.formData.dureeContrat = int.tryParse(v ?? "2028") ?? 2028,
        ),
        const SizedBox(height: 12),

        // ---- Salaire ----
        TextFormField(
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: fieldDecoration("Salaire (€/an)"),
          keyboardType: TextInputType.number,
          initialValue: widget.formData.salaire.toString(),
          onSaved: (v) =>
              widget.formData.salaire = int.tryParse(v ?? "10000") ?? 10000,
        ),
      ],
    );
  }
}
