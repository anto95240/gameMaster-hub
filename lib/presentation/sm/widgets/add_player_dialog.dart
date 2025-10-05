import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/common/enums.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';

class AddPlayerDialog extends StatefulWidget {
  const AddPlayerDialog({super.key});

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  int age = 18;
  int niveauActuel = 60;
  int potentiel = 80;
  int montantTransfert = 1000000;
  StatusEnum status = StatusEnum.Titulaire;
  int dureeContrat = 2028;
  int salaire = 10000;
  List<PosteEnum> postesSelectionnes = [];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(width);
    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;
    final isLaptop = screenType == ScreenType.laptop;
    
    final dialogWidth = isMobile 
        ? width * 0.95 
        : (isTablet ? 500.0 : (isLaptop ? 550.0 : 600.0));
    final padding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final spacing = isMobile ? 10.0 : 12.0;
    final titleSize = isMobile ? 20.0 : (isTablet ? 22.0 : 24.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ajouter un joueur",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: titleSize,
                        ),
                  ),
                  SizedBox(height: spacing * 1.5),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Nom"),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Nom obligatoire";
                      return null;
                    },
                    onSaved: (value) => nom = value!,
                  ),
                  SizedBox(height: spacing),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Âge"),
                    keyboardType: TextInputType.number,
                    initialValue: "18",
                    validator: (value) {
                      final v = int.tryParse(value ?? '');
                      if (v == null) return "Doit être un nombre";
                      if (v < 16) return "L'âge doit être ≥ 16";
                      return null;
                    },
                    onSaved: (value) => age = int.tryParse(value ?? "18") ?? 18,
                  ),
                  SizedBox(height: spacing),
                  MultiSelectDialogField<PosteEnum>(
                    items: PosteEnum.values
                        .map((p) => MultiSelectItem<PosteEnum>(p, p.name))
                        .toList(),
                    title: Text(
                      "Postes",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    buttonText: Text(
                      "Choisir les postes",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    itemsTextStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    confirmText: Text(
                      "OK",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    cancelText: Text(
                      "Annuler",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    onConfirm: (values) {
                      postesSelectionnes = values;
                    },
                    validator: (values) {
                      if (values == null || values.isEmpty) return "Sélectionner au moins un poste";
                      return null;
                    },
                  ),
                  SizedBox(height: spacing),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Niveau actuel"),
                    keyboardType: TextInputType.number,
                    initialValue: "60",
                    validator: (value) {
                      final v = int.tryParse(value ?? '');
                      if (v == null) return "Doit être un nombre";
                      if (v < 0 || v > 100) return "Doit être entre 0 et 100";
                      return null;
                    },
                    onSaved: (value) => niveauActuel = int.tryParse(value ?? "60") ?? 60,
                  ),
                  SizedBox(height: spacing),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Potentiel"),
                    keyboardType: TextInputType.number,
                    initialValue: "80",
                    validator: (value) {
                      final v = int.tryParse(value ?? '');
                      if (v == null) return "Doit être un nombre";
                      if (v < 0 || v > 100) return "Doit être entre 0 et 100";
                      return null;
                    },
                    onSaved: (value) => potentiel = int.tryParse(value ?? "80") ?? 80,
                  ),
                  SizedBox(height: spacing),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Fin de contrat"),
                    keyboardType: TextInputType.number,
                    initialValue: "2028",
                    onSaved: (value) => dureeContrat = int.tryParse(value ?? "2028") ?? 2028,
                  ),
                  SizedBox(height: spacing),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Salaire"),
                    keyboardType: TextInputType.number,
                    initialValue: "10000",
                    onSaved: (value) => salaire = int.tryParse(value ?? "10000") ?? 10000,
                  ),
                  SizedBox(height: spacing),
                  DropdownButtonFormField<StatusEnum>(
                    value: status,
                    decoration: const InputDecoration(labelText: "Statut"),
                    items: StatusEnum.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: (value) => status = value!,
                  ),
                  SizedBox(height: spacing * 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler"),
                      ),
                      SizedBox(width: spacing),
                      ElevatedButton(
                        onPressed: () => _handleSubmit(context),
                        child: const Text("Ajouter"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final response = await Supabase.instance.client
          .from('joueur_sm')
          .insert({
            'nom': nom,
            'age': age,
            'postes': postesSelectionnes.map((p) => p.name).toList(),
            'niveau_actuel': niveauActuel,
            'potentiel': potentiel,
            'montant_transfert': montantTransfert,
            'status': status.name,
            'duree_contrat': dureeContrat,
            'salaire': salaire,
            'user_id': Supabase.instance.client.auth.currentUser!.id,
          })
          .select('id')
          .single();

      final joueurId = response['id'] != null ? response['id'] as int : null;

      if (joueurId == null) {
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser!.id;

      await Supabase.instance.client.from('stats_joueur_sm').insert({
        'user_id': userId,
        'joueur_id': joueurId,
        'marquage': 50,
        'deplacement': 50,
        'frappes_lointaines': 50,
        'passes_longues': 50,
        'coups_francs': 50,
        'tacles': 50,
        'finition': 50,
        'centres': 50,
        'passes': 50,
        'corners': 50,
        'positionnement': 50,
        'dribble': 50,
        'controle': 50,
        'penalties': 50,
        'creativite': 50,
        'stabilite_aerienne': 50,
        'vitesse': 50,
        'endurance': 50,
        'force': 50,
        'distance_parcourue': 50,
        'agressivite': 50,
        'sang_froid': 50,
        'concentration': 50,
        'flair': 50,
        'leadership': 50,
      });

      if (mounted) {
        context.read<JoueursSmBloc>().add(LoadJoueursSmEvent());
        Navigator.pop(context);
      }
    }
  }
}