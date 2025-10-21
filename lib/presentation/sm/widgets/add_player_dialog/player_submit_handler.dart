import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/add_player_dialog/player_form_fields.dart';
import 'package:gamemaster_hub/main.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';


Future<void> handlePlayerSubmit(
    BuildContext context, GlobalKey<FormState> formKey, PlayerFormData formData) async {
  if (!formKey.currentState!.validate()) return;

  formKey.currentState!.save();

  final response = await Supabase.instance.client.from('joueur_sm').insert({
    'nom': formData.nom,
    'age': formData.age,
    'postes': formData.postesSelectionnes.map((p) => p.name).toList(),
    'niveau_actuel': formData.niveauActuel,
    'potentiel': formData.potentiel,
    'montant_transfert': formData.montantTransfert,
    'status': formData.status.name,
    'duree_contrat': formData.dureeContrat,
    'salaire': formData.salaire,
    'user_id': Supabase.instance.client.auth.currentUser!.id,
    'save_id': globalSaveId,
  }).select('id').single();

  final joueurId = response['id'] as int?;

  if (joueurId != null) {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    await Supabase.instance.client.from('stats_joueur_sm').insert({
      'user_id': userId,
      'joueur_id': joueurId,
      'save_id': globalSaveId,
      ...Map.fromIterable(
        List.generate(26, (_) => 50),
        key: (i) => [
          'marquage',
          'deplacement',
          'frappes_lointaines',
          'passes_longues',
          'coups_francs',
          'tacles',
          'finition',
          'centres',
          'passes',
          'corners',
          'positionnement',
          'dribble',
          'controle',
          'penalties',
          'creativite',
          'stabilite_aerienne',
          'vitesse',
          'endurance',
          'force',
          'distance_parcourue',
          'agressivite',
          'sang_froid',
          'concentration',
          'flair',
          'leadership',
        ][i],
        value: (i) => 50,
      ),
    });

    if (context.mounted) {
      context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(globalSaveId));
      Navigator.pop(context);
    }
  }
}
