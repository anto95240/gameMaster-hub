import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class PlayerInfoBody extends StatelessWidget {
  final JoueurSmWithStats item;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;
  final Function(Map<String, int>)? onRatingsChanged;
  final Function(int, int)? onValueSalaryChanged;
  final Function(List<PosteEnum>)? onPostesChanged;
  final Function(int)? onDurationChanged;

  const PlayerInfoBody({
    super.key,
    required this.item,
    required this.isEditing,
    required this.onEditingChanged,
    this.onRatingsChanged,
    this.onValueSalaryChanged,
    this.onPostesChanged,
    this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final joueur = item.joueur;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlayerAvatar(joueur: joueur),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayerPostesSection(
                  joueur: joueur, 
                  isEditing: isEditing,
                  onPostesChanged: onPostesChanged,
                ),
                const SizedBox(height: 12),
                PlayerContractSection(
                  joueur: joueur, 
                  isEditing: isEditing,
                  onDurationChanged: onDurationChanged,
                ),
                const SizedBox(height: 12),
                PlayerRatingsSection(
                  joueur: joueur,
                  isEditing: isEditing,
                  onRatingsChanged: onRatingsChanged ?? (map) {},
                ),
                const SizedBox(height: 12),
                PlayerValueSalarySection(
                  joueur: joueur,
                  isEditing: isEditing,
                  onChanged: onValueSalaryChanged ?? (value, salary) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
