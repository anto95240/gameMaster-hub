import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class PlayerStatsGardienForm extends StatefulWidget {
  final StatsGardienSm? stats;
  final bool isEditing;

  const PlayerStatsGardienForm({
    super.key,
    required this.stats,
    required this.isEditing,
  });

  @override
  State<PlayerStatsGardienForm> createState() => _PlayerStatsGardienFormState();
}

class _PlayerStatsGardienFormState extends State<PlayerStatsGardienForm> {
  late Map<String, TextEditingController> statsControllers;

  @override
  void initState() {
    super.initState();
    _initStatsControllers();
  }

  void _initStatsControllers() {
    final stats = widget.stats;
    statsControllers = {};

    if (stats != null) {
      statsControllers['autorite_surface'] =
          TextEditingController(text: stats.autoriteSurface.toString());
      statsControllers['distribution'] =
          TextEditingController(text: stats.distribution.toString());
      statsControllers['captation'] =
          TextEditingController(text: stats.captation.toString());
      statsControllers['duels'] =
          TextEditingController(text: stats.duels.toString());
      statsControllers['arrets'] =
          TextEditingController(text: stats.arrets.toString());
      statsControllers['positionnement'] =
          TextEditingController(text: stats.positionnement.toString());
      statsControllers['penalties'] =
          TextEditingController(text: stats.penalties.toString());

      // Physique
      statsControllers['stabilite_aerienne'] =
          TextEditingController(text: stats.stabiliteAerienne.toString());
      statsControllers['vitesse'] =
          TextEditingController(text: stats.vitesse.toString());
      statsControllers['force'] =
          TextEditingController(text: stats.force.toString());

      // Mental
      statsControllers['agressivite'] =
          TextEditingController(text: stats.agressivite.toString());
      statsControllers['sang_froid'] =
          TextEditingController(text: stats.sangFroid.toString());
      statsControllers['concentration'] =
          TextEditingController(text: stats.concentration.toString());
      statsControllers['leadership'] =
          TextEditingController(text: stats.leadership.toString());
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
        Text(
          'Statistiques du Gardien',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
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
                              labelText: key.replaceAll('_', ' '),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          )
                        : Column(
                            children: [
                              Text(
                                key.replaceAll('_', ' '),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                statsControllers[key]!.text.isEmpty
                                    ? '-'
                                    : statsControllers[key]!.text,
                                textAlign: TextAlign.center,
                              ),
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
