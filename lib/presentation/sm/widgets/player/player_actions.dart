import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class PlayerActions extends StatelessWidget {
  final JoueurSmWithStats item;
  final bool isEditing;
  final VoidCallback onCancel;
  final ValueChanged<bool> onEditChanged;
  final int saveId;
  final GlobalKey<PlayerInfoFormState>? playerInfoFormKey;
  final GlobalKey<PlayerStatsFormState>? playerStatsFormKey;
  final Function()? onSave;
  final Function()? onUpdateSuccess;

  const PlayerActions({
    super.key,
    required this.item,
    required this.isEditing,
    required this.onCancel,
    required this.onEditChanged,
    required this.saveId,
    this.playerInfoFormKey,
    this.playerStatsFormKey,
    this.onSave,
    this.onUpdateSuccess,
  });

  Future<void> _savePlayer(BuildContext context) async {
    if (onSave != null) {
      onSave!();
    } else if (playerInfoFormKey != null && playerStatsFormKey != null) {
      final playerData = playerInfoFormKey!.currentState?.getFormData() ?? {};
      final statsData = playerStatsFormKey!.currentState?.getStatsData() ?? {};
      
      if (playerData['nom'] == null || playerData['nom'].toString().trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le nom du joueur ne peut pas être vide'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      await handlePlayerUpdate(
        context,
        item,
        playerData,
        statsData,
        saveId,
        onUpdateSuccess,
      );
      
      onEditChanged(false);
    } else {
      onEditChanged(false);
    }
  }

  Future<void> _deletePlayer(BuildContext context) async {
    final playerId = item.joueur.id;
    // ✅ CORRECTION: 'G' au lieu de 'GK'
    final isGK = item.joueur.postes.any((p) => p.name == 'G');
    
    if (isGK) {
      await Supabase.instance.client
          .from('stats_gardien_sm')
          .delete()
          .eq('joueur_id', playerId);
    } else {
      await Supabase.instance.client
          .from('stats_joueur_sm')
          .delete()
          .eq('joueur_id', playerId);
    }
    
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isEditing ? () => _savePlayer(context) : () => onEditChanged(!isEditing),
                        icon: Icon(isEditing ? Icons.save : Icons.edit),
                        label: Text(isEditing ? 'Enregistrer' : 'Modifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEditing ? Colors.green : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deletePlayer(context),
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isEditing) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Annuler'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ],
            )
          : Row(
              children: [
                if (isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('Annuler'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (isEditing) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isEditing ? () => _savePlayer(context) : () => onEditChanged(!isEditing),
                    icon: Icon(isEditing ? Icons.save : Icons.edit),
                    label: Text(isEditing ? 'Enregistrer' : 'Modifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deletePlayer(context),
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}