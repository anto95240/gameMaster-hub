import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/common/enums.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';
import 'package:gamemaster_hub/main.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerDetailsDialog extends StatefulWidget {
  final JoueurSmWithStats item;

  const PlayerDetailsDialog({
    super.key,
    required this.item,
  });

  @override
  State<PlayerDetailsDialog> createState() => _PlayerDetailsDialogState();
}

class _PlayerDetailsDialogState extends State<PlayerDetailsDialog> {
  bool isEditing = false;
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController ratingController;
  late TextEditingController potentielController;
  late TextEditingController valueController;
  late TextEditingController dureeContratController;
  late TextEditingController salaireController;
  late String selectedStatus;
  List<PosteEnum> selectedPostes = [];
  late Map<String, TextEditingController> statsControllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final joueur = widget.item.joueur;
    final stats = widget.item.stats;

    nameController = TextEditingController(text: joueur.nom);
    ageController = TextEditingController(text: joueur.age.toString());
    ratingController = TextEditingController(text: joueur.niveauActuel.toString());
    potentielController = TextEditingController(text: joueur.potentiel.toString());
    valueController = TextEditingController(text: joueur.montantTransfert.toString());
    dureeContratController = TextEditingController(text: joueur.dureeContrat.toString());
    salaireController = TextEditingController(text: joueur.salaire.toString());
    selectedStatus = joueur.status.name;
    selectedPostes = joueur.postes;

    statsControllers = {};
    if (stats != null) {
      statsControllers['marquage'] = TextEditingController(text: stats.marquage.toString());
      statsControllers['deplacement'] = TextEditingController(text: stats.deplacement.toString());
      statsControllers['frappes_lointaines'] = TextEditingController(text: stats.frappesLointaines.toString());
      statsControllers['passes_longues'] = TextEditingController(text: stats.passesLongues.toString());
      statsControllers['coups_francs'] = TextEditingController(text: stats.coupsFrancs.toString());
      statsControllers['tacles'] = TextEditingController(text: stats.tacles.toString());
      statsControllers['finition'] = TextEditingController(text: stats.finition.toString());
      statsControllers['centres'] = TextEditingController(text: stats.centres.toString());
      statsControllers['passes'] = TextEditingController(text: stats.passes.toString());
      statsControllers['corners'] = TextEditingController(text: stats.corners.toString());
      statsControllers['positionnement'] = TextEditingController(text: stats.positionnement.toString());
      statsControllers['dribble'] = TextEditingController(text: stats.dribble.toString());
      statsControllers['controle'] = TextEditingController(text: stats.controle.toString());
      statsControllers['penalties'] = TextEditingController(text: stats.penalties.toString());
      statsControllers['creativite'] = TextEditingController(text: stats.creativite.toString());
      statsControllers['stabilite_aerienne'] = TextEditingController(text: stats.stabiliteAerienne.toString());
      statsControllers['vitesse'] = TextEditingController(text: stats.vitesse.toString());
      statsControllers['endurance'] = TextEditingController(text: stats.endurance.toString());
      statsControllers['force'] = TextEditingController(text: stats.force.toString());
      statsControllers['distance_parcourue'] = TextEditingController(text: stats.distanceParcourue.toString());
      statsControllers['agressivite'] = TextEditingController(text: stats.agressivite.toString());
      statsControllers['sang_froid'] = TextEditingController(text: stats.sangFroid.toString());
      statsControllers['concentration'] = TextEditingController(text: stats.concentration.toString());
      statsControllers['flair'] = TextEditingController(text: stats.flair.toString());
      statsControllers['leadership'] = TextEditingController(text: stats.leadership.toString());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    ratingController.dispose();
    potentielController.dispose();
    valueController.dispose();
    dureeContratController.dispose();
    salaireController.dispose();
    for (final c in statsControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      final updatedStats = <String, int>{};
      statsControllers.forEach((key, controller) {
        updatedStats[key] = int.tryParse(controller.text) ?? 0;
      });

      await Supabase.instance.client
          .from('joueur_sm')
          .update({
            'nom': nameController.text,
            'age': int.parse(ageController.text),
            'postes': selectedPostes.map((p) => p.name).toList(),
            'niveau_actuel': int.parse(ratingController.text),
            'potentiel': int.parse(potentielController.text),
            'montant_transfert': int.parse(valueController.text),
            'status': selectedStatus,
            'duree_contrat': int.parse(dureeContratController.text),
            'salaire': int.parse(salaireController.text),
          })
          .eq('id', widget.item.joueur.id);

      await Supabase.instance.client
          .from('stats_joueur_sm')
          .update(updatedStats)
          .eq('joueur_id', widget.item.joueur.id);

      setState(() {
        isEditing = false;
      });

      if (mounted) {
        context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(globalSaveId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${nameController.text} a été mis à jour')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }

  Future<void> _deletePlayer() async {
    try {
      final playerId = widget.item.joueur.id;

      await Supabase.instance.client
          .from('stats_joueur_sm')
          .delete()
          .eq('joueur_id', playerId);

      await Supabase.instance.client
          .from('joueur_sm')
          .delete()
          .eq('id', playerId);

      if (mounted) {
        context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(globalSaveId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.item.joueur.nom} a été supprimé')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : $e')),
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false;
      _initializeControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final joueur = widget.item.joueur;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(context, joueur),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlayerInfo(context, joueur),
                    const SizedBox(height: 32),
                    Text(
                      'Statistiques détaillées',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildStatsSection(context, "Technique", [
                      'marquage', 'deplacement', 'frappes_lointaines', 'passes_longues',
                      'coups_francs', 'tacles', 'finition', 'centres', 'passes', 'corners',
                      'positionnement', 'dribble', 'controle', 'penalties', 'creativite',
                    ]),
                    const SizedBox(height: 16),
                    _buildStatsSection(context, "Physique", [
                      'stabilite_aerienne', 'vitesse', 'endurance', 'force', 'distance_parcourue',
                    ]),
                    const SizedBox(height: 16),
                    _buildStatsSection(context, "Mental", [
                      'agressivite', 'sang_froid', 'concentration', 'flair', 'leadership',
                    ]),
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, JoueurSm joueur) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: isEditing
                ? TextField(
                    controller: nameController,
                    style: Theme.of(context).textTheme.headlineMedium,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nom',
                    ),
                  )
                : Text(
                    joueur.nom,
                    style: Theme.of(context).textTheme.headlineMedium,
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

  Widget _buildPlayerInfo(BuildContext context, JoueurSm joueur) {
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(MediaQuery.of(context).size.width);
    final isMobile = screenType == ScreenType.mobile;

    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              joueur.nom[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Statut
          if (isEditing)
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Statut',
                border: OutlineInputBorder(),
              ),
              items: StatusEnum.values
                  .map((s) => DropdownMenuItem(
                        value: s.name,
                        child: Text(s.name),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedStatus = value!),
            )
          else
            Text(
              joueur.status.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 8),

          // Poste + âge
          _buildEditableFields(context, joueur), // déjà en colonne/row adaptative
        ],
      );
    } else {
      // Desktop / tablet : layout original en Row
      return Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              joueur.nom[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditing) ...[
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                    ),
                    items: StatusEnum.values
                        .map((s) => DropdownMenuItem(
                              value: s.name,
                              child: Text(s.name),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedStatus = value!),
                  ),
                ] else ...[
                  Text(
                    joueur.status.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
                const SizedBox(height: 8),
                _buildEditableFields(context, joueur),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildEditableFields(BuildContext context, JoueurSm joueur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEditing)
          TextField(
            controller: dureeContratController,
            decoration: const InputDecoration(
              labelText: 'Fin de contrat',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          )
        else
          Text(
            "Contrat jusqu'à ${joueur.dureeContrat}",
            style: Theme.of(context).textTheme.titleMedium,
          ),

        const SizedBox(height: 8),

        Row(
          children: [
            if (isEditing)
              Expanded(
                child: MultiSelectDialogField<PosteEnum>(
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
                    selectedPostes.map((e) => e.name).join("/"),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  initialValue: selectedPostes,
                  itemsTextStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  confirmText: Text(
                    "OK",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  cancelText: Text(
                    "Annuler",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  onConfirm: (values) {
                    setState(() {
                      selectedPostes = values;
                    });
                  },
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPositionColor(joueur.postes.first.name).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  joueur.postes.map((e) => e.name).join("/"),
                  style: TextStyle(
                    color: _getPositionColor(joueur.postes.first.name),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            if (isEditing)
              SizedBox(
                width: 80,
                child: TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Âge',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            else
              Text('${joueur.age} ans'),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            if (isEditing)
              SizedBox(
                width: 80,
                child: TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRatingColor(joueur.niveauActuel).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  joueur.niveauActuel.toString(),
                  style: TextStyle(
                    color: _getRatingColor(joueur.niveauActuel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(width: 8),

            if (isEditing)
              SizedBox(
                width: 80,
                child: TextField(
                  controller: potentielController,
                  decoration: const InputDecoration(
                    labelText: 'Pot.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getProgressionColor(joueur.potentiel).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  joueur.potentiel.toString(),
                  style: TextStyle(
                    color: _getProgressionColor(joueur.potentiel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            if (isEditing)
              SizedBox(
                width: 100,
                child: TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Val. (M€)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            else
              Text(
                "${joueur.montantTransfert} M€",
                style: Theme.of(context).textTheme.titleMedium
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, String title, List<String> keys) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Center( // <-- Ajouté pour centrer le Wrap
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center, // facultatif mais cohérent
                children: keys.map((key) {
                  if (!statsControllers.containsKey(key)) return const SizedBox();
                  return SizedBox(
                    width: 150,
                    child: isEditing
                        ? TextField(
                            controller: statsControllers[key],
                            decoration: InputDecoration(
                              labelText: key,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          )
                        : Column(
                            children: [
                              Text(
                                key,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(statsControllers[key]!.text),
                            ],
                          ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(MediaQuery.of(context).size.width);
    final isMobile = screenType == ScreenType.mobile;

    // On ne met Expanded que pour desktop/tablet
    final buttons = <Widget>[
      if (isEditing)
        OutlinedButton(
          onPressed: _cancelEdit,
          child: const Text('Annuler'),
        ),
      OutlinedButton.icon(
        onPressed: isEditing
            ? _saveChanges
            : () {
                setState(() {
                  isEditing = true;
                });
              },
        icon: Icon(isEditing ? Icons.save : Icons.edit),
        label: Text(isEditing ? 'Enregistrer' : 'Modifier'),
      ),
      OutlinedButton.icon(
        onPressed: _deletePlayer,
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
                  .map((b) => Expanded(child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: b,
                      )))
                  .toList(),
            ),
    );
  }

  Color _getPositionColor(String position) {
    switch (position) {
      case 'ATT':
      case 'BU':
      case 'MOD':
      case 'MOG':
        return Colors.red;
      case 'MIL':
      case 'MC':
      case 'MDC':
      case 'MOC':
      case 'MD':
      case 'MG':
        return Colors.green;
      case 'DEF':
      case 'DC':
      case 'DL':
      case 'DR':
      case 'DG':
      case 'DD':
      case 'DOG':
      case 'DOD':
        return Colors.blue;
      case 'GK':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

    Color _getRatingColor(int rating) {
    if (rating >= 85) return Colors.green;
    if (rating >= 80) return Colors.blue;
    return Colors.orange;
  }

  Color _getProgressionColor(int potentiel) {
    if (potentiel > 0) return Colors.green;
    if (potentiel < 0) return Colors.red;
    return Colors.grey;
  }
}
