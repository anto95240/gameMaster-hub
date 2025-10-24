import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/sm/entities/stats_joueur_sm.dart';
import 'package:gamemaster_hub/domain/sm/entities/stats_gardien_sm.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

class PlayerStatsForm extends StatefulWidget {
  final JoueurSmWithStats item;
  final bool isEditing;

  const PlayerStatsForm({
    super.key,
    required this.item,
    required this.isEditing,
  });

  @override
  State<PlayerStatsForm> createState() => _PlayerStatsFormState();
}

class _PlayerStatsFormState extends State<PlayerStatsForm> {
  late Map<String, TextEditingController> statsControllers;
  late bool isGardien;

  @override
  void initState() {
    super.initState();
    isGardien = widget.item.joueur.postes.any((p) => p.name == 'GK');
    _initStatsControllers();
  }

  void _initStatsControllers() {
    statsControllers = {};

    final stats = widget.item.stats;

    if (stats == null) return;

    if (stats is StatsJoueurSm) {
      // ⚽ Joueur de champ
      statsControllers = {
        'marquage': TextEditingController(text: stats.marquage.toString()),
        'deplacement': TextEditingController(text: stats.deplacement.toString()),
        'frappes_lointaines': TextEditingController(text: stats.frappesLointaines.toString()),
        'passes_longues': TextEditingController(text: stats.passesLongues.toString()),
        'coups_francs': TextEditingController(text: stats.coupsFrancs.toString()),
        'tacles': TextEditingController(text: stats.tacles.toString()),
        'finition': TextEditingController(text: stats.finition.toString()),
        'centres': TextEditingController(text: stats.centres.toString()),
        'passes': TextEditingController(text: stats.passes.toString()),
        'corners': TextEditingController(text: stats.corners.toString()),
        'positionnement': TextEditingController(text: stats.positionnement.toString()),
        'dribble': TextEditingController(text: stats.dribble.toString()),
        'controle': TextEditingController(text: stats.controle.toString()),
        'penalties': TextEditingController(text: stats.penalties.toString()),
        'creativite': TextEditingController(text: stats.creativite.toString()),
        'stabilite_aerienne': TextEditingController(text: stats.stabiliteAerienne.toString()),
        'vitesse': TextEditingController(text: stats.vitesse.toString()),
        'endurance': TextEditingController(text: stats.endurance.toString()),
        'force': TextEditingController(text: stats.force.toString()),
        'distance_parcourue': TextEditingController(text: stats.distanceParcourue.toString()),
        'agressivite': TextEditingController(text: stats.agressivite.toString()),
        'sang_froid': TextEditingController(text: stats.sangFroid.toString()),
        'concentration': TextEditingController(text: stats.concentration.toString()),
        'flair': TextEditingController(text: stats.flair.toString()),
        'leadership': TextEditingController(text: stats.leadership.toString()),
      };
    } else if (stats is StatsGardienSm) {
      // 🧤 Gardien
      statsControllers = {
        'autorite_surface': TextEditingController(text: stats.autoriteSurface.toString()),
        'distribution': TextEditingController(text: stats.distribution.toString()),
        'captation': TextEditingController(text: stats.captation.toString()),
        'duels': TextEditingController(text: stats.duels.toString()),
        'arrets': TextEditingController(text: stats.arrets.toString()),
        'positionnement': TextEditingController(text: stats.positionnement.toString()),
        'penalties': TextEditingController(text: stats.penalties.toString()),
        'stabilite_aerienne': TextEditingController(text: stats.stabiliteAerienne.toString()),
        'vitesse': TextEditingController(text: stats.vitesse.toString()),
        'force': TextEditingController(text: stats.force.toString()),
        'agressivite': TextEditingController(text: stats.agressivite.toString()),
        'sang_froid': TextEditingController(text: stats.sangFroid.toString()),
        'concentration': TextEditingController(text: stats.concentration.toString()),
        'leadership': TextEditingController(text: stats.leadership.toString()),
      };
    }
  }

  @override
  void dispose() {
    for (final c in statsControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (statsControllers.isEmpty) {
      return const Text("Aucune statistique disponible");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isGardien ? 'Statistiques du gardien' : 'Statistiques détaillées',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._buildSections(),
      ],
    );
  }

  List<Widget> _buildSections() {
    if (isGardien) {
      return [
        _buildStatsSection('Technique', [
          'autorite_surface',
          'distribution',
          'captation',
          'duels',
          'arrets',
          'positionnement',
          'penalties',
        ]),
        const SizedBox(height: 16),
        _buildStatsSection('Physique', [
          'stabilite_aerienne',
          'vitesse',
          'force',
        ]),
        const SizedBox(height: 16),
        _buildStatsSection('Mental', [
          'agressivite',
          'sang_froid',
          'concentration',
          'leadership',
        ]),
      ];
    } else {
      return [
        _buildStatsSection('Technique', [
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
        ]),
        const SizedBox(height: 16),
        _buildStatsSection('Physique', [
          'stabilite_aerienne',
          'vitesse',
          'endurance',
          'force',
          'distance_parcourue',
        ]),
        const SizedBox(height: 16),
        _buildStatsSection('Mental', [
          'agressivite',
          'sang_froid',
          'concentration',
          'flair',
          'leadership',
        ]),
      ];
    }
  }

  Widget _buildStatsSection(String title, List<String> keys) {
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
            Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: keys.map((key) {
                  if (!statsControllers.containsKey(key)) return const SizedBox();
                  return SizedBox(
                    width: 150,
                    child: widget.isEditing
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
                              Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
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
}
