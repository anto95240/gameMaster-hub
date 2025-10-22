import 'package:flutter/material.dart';

import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_info_form.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_stats_form.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_actions.dart';

class PlayerDetailsDialog extends StatefulWidget {
  final JoueurSmWithStats item;
  final int saveId; // ← ajouté

  const PlayerDetailsDialog({super.key, required this.item, required this.saveId});

  @override
  State<PlayerDetailsDialog> createState() => _PlayerDetailsDialogState();
}

class _PlayerDetailsDialogState extends State<PlayerDetailsDialog> {
  bool isEditing = false;

  void toggleEditing(bool val) => setState(() => isEditing = val);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            PlayerInfoForm(
              item: widget.item,
              isEditing: isEditing,
              onEditingChanged: toggleEditing,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: PlayerStatsForm(
                  item: widget.item,
                  isEditing: isEditing,
                ),
              ),
            ),
            PlayerActions(
              item: widget.item,
              isEditing: isEditing,
              onCancel: () => toggleEditing(false),
              onEditChanged: toggleEditing,
              saveId: widget.saveId, // ← ajouté
            ),
          ],
        ),
      ),
    );
  }
}
