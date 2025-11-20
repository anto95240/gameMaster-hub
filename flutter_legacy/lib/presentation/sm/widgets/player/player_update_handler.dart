import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc_export.dart';

Future<void> handlePlayerUpdate(
  BuildContext context,
  JoueurSmWithStats item,
  Map<String, dynamic> playerData,
  Map<String, int> statsData,
  int saveId,
  Function()? onUpdateSuccess,
) async {
  try {
    final playerId = item.joueur.id;
    final isGK = item.joueur.postes.any((p) => p.name == 'G');

    await Supabase.instance.client.from('joueur_sm').update({
      'nom': playerData['nom'],
      'age': playerData['age'],
      'niveau_actuel': playerData['niveau_actuel'],
      'potentiel': playerData['potentiel'],
      'montant_transfert': playerData['montant_transfert'],
      'duree_contrat': playerData['duree_contrat'],
      'salaire': playerData['salaire'],
      'status': playerData['status'],
      'postes': playerData['postes'],
    }).eq('id', playerId);

    if (isGK) {
      await Supabase.instance.client.from('stats_gardien_sm').update({
        'autorite_surface': statsData['autorite_surface'] ?? 50,
        'distribution': statsData['distribution'] ?? 50,
        'captation': statsData['captation'] ?? 50,
        'duels': statsData['duels'] ?? 50,
        'arrets': statsData['arrets'] ?? 50,
        'positionnement': statsData['positionnement'] ?? 50,
        'penalties': statsData['penalties'] ?? 50,
        'stabilite_aerienne': statsData['stabilite_aerienne'] ?? 50,
        'vitesse': statsData['vitesse'] ?? 50,
        'force': statsData['force'] ?? 50,
        'agressivite': statsData['agressivite'] ?? 50,
        'sang_froid': statsData['sang_froid'] ?? 50,
        'concentration': statsData['concentration'] ?? 50,
        'leadership': statsData['leadership'] ?? 50,
      }).eq('joueur_id', playerId);
    } else {
      await Supabase.instance.client.from('stats_joueur_sm').update({
        'marquage': statsData['marquage'] ?? 50,
        'deplacement': statsData['deplacement'] ?? 50,
        'frappes_lointaines': statsData['frappes_lointaines'] ?? 50,
        'passes_longues': statsData['passes_longues'] ?? 50,
        'coups_francs': statsData['coups_francs'] ?? 50,
        'tacles': statsData['tacles'] ?? 50,
        'finition': statsData['finition'] ?? 50,
        'centres': statsData['centres'] ?? 50,
        'passes': statsData['passes'] ?? 50,
        'corners': statsData['corners'] ?? 50,
        'positionnement': statsData['positionnement'] ?? 50,
        'dribble': statsData['dribble'] ?? 50,
        'controle': statsData['controle'] ?? 50,
        'penalties': statsData['penalties'] ?? 50,
        'creativite': statsData['creativite'] ?? 50,
        'stabilite_aerienne': statsData['stabilite_aerienne'] ?? 50,
        'vitesse': statsData['vitesse'] ?? 50,
        'endurance': statsData['endurance'] ?? 50,
        'force': statsData['force'] ?? 50,
        'distance_parcourue': statsData['distance_parcourue'] ?? 50,
        'agressivite': statsData['agressivite'] ?? 50,
        'sang_froid': statsData['sang_froid'] ?? 50,
        'concentration': statsData['concentration'] ?? 50,
        'flair': statsData['flair'] ?? 50,
        'leadership': statsData['leadership'] ?? 50,
      }).eq('joueur_id', playerId);
    }

    if (context.mounted) {
      context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(saveId));
      
      onUpdateSuccess?.call(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${playerData['nom']} a été mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}