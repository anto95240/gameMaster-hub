import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_info/player_info_body.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_info/player_info_header.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_stats_form.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_actions.dart';

class PlayerDetailsDialog extends StatefulWidget {
  final JoueurSmWithStats item;
  final int saveId;

  const PlayerDetailsDialog({
    super.key,
    required this.item,
    required this.saveId,
  });

  @override
  State<PlayerDetailsDialog> createState() => _PlayerDetailsDialogState();
}

class _PlayerDetailsDialogState extends State<PlayerDetailsDialog> {
  bool isEditing = false;

  void toggleEditing(bool val) => setState(() => isEditing = val);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 750),
        child: Column(
          children: [
            /// 🔹 En-tête du joueur
            PlayerInfoHeader(
              item: widget.item,
              isEditing: isEditing,
              onEditingChanged: toggleEditing,
            ),

            /// 🔹 Corps avec info + stats
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    PlayerInfoBody(
                      item: widget.item,
                      isEditing: isEditing,
                      onEditingChanged: toggleEditing,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: PlayerStatsForm(
                        item: widget.item,
                        isEditing: isEditing,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 🔹 Boutons (Modifier / Supprimer / Annuler)
            PlayerActions(
              item: widget.item,
              isEditing: isEditing,
              onCancel: () => toggleEditing(false),
              onEditChanged: toggleEditing,
              saveId: widget.saveId,
            ),
          ],
        ),
      ),
    );
  }
}
