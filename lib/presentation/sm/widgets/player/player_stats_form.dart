import 'package:flutter/material.dart';

import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

class PlayerStatsForm extends StatefulWidget {
  final JoueurSmWithStats item;
  final bool isEditing;

  const PlayerStatsForm({super.key, required this.item, required this.isEditing});

  @override
  State<PlayerStatsForm> createState() => _PlayerStatsFormState();
}

class _PlayerStatsFormState extends State<PlayerStatsForm> {
  late Map<String, TextEditingController> statsControllers;

  @override
  void initState() {
    super.initState();
    _initStatsControllers();
  }

  void _initStatsControllers() {
    final stats = widget.item.stats;
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
    for (final c in statsControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsSection('Technique', [
          'marquage', 'deplacement', 'frappes_lointaines', 'passes_longues',
          'coups_francs', 'tacles', 'finition', 'centres', 'passes', 'corners',
          'positionnement', 'dribble', 'controle', 'penalties', 'creativite',
        ]),
        const SizedBox(height: 16),
        _buildStatsSection('Physique', [
          'stabilite_aerienne', 'vitesse', 'endurance', 'force', 'distance_parcourue',
        ]),
        const SizedBox(height: 16),
        _buildStatsSection('Mental', [
          'agressivite', 'sang_froid', 'concentration', 'flair', 'leadership',
        ]),
      ],
    );
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
