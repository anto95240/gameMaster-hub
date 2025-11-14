import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

Future<void> handlePlayerSubmit(
    BuildContext context,
    GlobalKey<FormState> formKey,
    PlayerFormData formData,
    int saveId
    ) async {
  if (formData.postesSelectionnes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez sélectionner au moins un poste'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

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
    'save_id': saveId,
  }).select('id').single();

  final joueurId = response['id'] as int?;

  if (joueurId != null) {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final isGK = formData.postesSelectionnes.any((p) => p.name == 'G');

    if (isGK) {
      await Supabase.instance.client.from('stats_gardien_sm').insert({
        'user_id': userId,
        'joueur_id': joueurId,
        'save_id': saveId,
        for (final attr in [
          'autorite_surface',
          'distribution',
          'captation',
          'duels',
          'arrets',
          'positionnement',
          'penalties',
          'stabilite_aerienne',
          'vitesse',
          'force',
          'agressivite',
          'sang_froid',
          'concentration',
          'leadership',
        ])
          attr: 50,
      });
    } else {
      await Supabase.instance.client.from('stats_joueur_sm').insert({
        'user_id': userId,
        'joueur_id': joueurId,
        'save_id': saveId,
        for (final attr in [
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
        ])
          attr: 50,
      });
    }

    if (context.mounted) {
      context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(saveId));
      Navigator.pop(context);
    }
  }
}