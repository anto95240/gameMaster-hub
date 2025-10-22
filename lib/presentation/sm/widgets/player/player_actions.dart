import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

class PlayerActions extends StatelessWidget {
  final JoueurSmWithStats item;
  final bool isEditing;
  final VoidCallback onCancel;
  final ValueChanged<bool> onEditChanged;
  final int saveId;

  const PlayerActions({
    super.key,
    required this.item,
    required this.isEditing,
    required this.onCancel,
    required this.onEditChanged,
    required this.saveId,
  });

  Future<void> _deletePlayer(BuildContext context) async {
    final playerId = item.joueur.id;
    await Supabase.instance.client
        .from('stats_joueur_sm')
        .delete()
        .eq('joueur_id', playerId);
    await Supabase.instance.client.from('joueur_sm').delete().eq('id', playerId);

    if (context.mounted) {
      context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(saveId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.joueur.nom} a été supprimé')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final buttons = <Widget>[
      if (isEditing)
        OutlinedButton(onPressed: onCancel, child: const Text('Annuler')),
      OutlinedButton.icon(
        onPressed: () => onEditChanged(!isEditing),
        icon: Icon(isEditing ? Icons.save : Icons.edit),
        label: Text(isEditing ? 'Enregistrer' : 'Modifier'),
      ),
      OutlinedButton.icon(
        onPressed: () => _deletePlayer(context),
        icon: const Icon(Icons.delete),
        label: const Text('Supprimer'),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buttons
                  .map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: b,
                      ))
                  .toList(),
            )
          : Row(
              children: buttons
                  .map((b) => Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 8), child: b),
                      ))
                  .toList(),
            ),
    );
  }
}
