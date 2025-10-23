import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

class PlayerInfoHeader extends StatelessWidget {
  final JoueurSmWithStats item;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;

  const PlayerInfoHeader({
    super.key,
    required this.item,
    required this.isEditing,
    required this.onEditingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final joueur = item.joueur;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor =
        isDark ? const Color(0xFF2C2C3A) : const Color(0xFFE5E7EB);

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
        children: [
          Expanded(
            child: isEditing
                ? TextField(
                    controller: TextEditingController(text: joueur.nom),
                    decoration: const InputDecoration(
                      labelText: 'Nom du joueur',
                      border: OutlineInputBorder(),
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  )
                : Text(
                    joueur.nom,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
