import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class PlayerInfoHeader extends StatelessWidget {
  final JoueurSmWithStats item;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;
  final TextEditingController? nameController;
  final TextEditingController? ageController;

  const PlayerInfoHeader({
    super.key,
    required this.item,
    required this.isEditing,
    required this.onEditingChanged,
    this.nameController,
    this.ageController,
  });

  @override
  Widget build(BuildContext context) {
    final joueur = item.joueur;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor =
        isDark ? const Color(0xFF2C2C3A) : const Color(0xFFE5E7EB);

    final nameCtrl =
        nameController ?? TextEditingController(text: joueur.nom);
    final ageCtrl =
        ageController ?? TextEditingController(text: joueur.age.toString());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: isEditing
                ? TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nom du joueur',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  )
                : Text(
                    joueur.nom,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
          ),

          const SizedBox(width: 16),

          SizedBox(
            width: 80,
            child: isEditing
                ? TextField(
                    controller: ageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Âge',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  )
                : Text(
                    "${joueur.age} ans",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
          ),

          const SizedBox(width: 12),

          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Fermer',
          ),
        ],
      ),
    );
  }
}
