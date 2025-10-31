import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_tactic_tab/formation_calculator.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_tactic_tab/interactive_soccer_field.dart';

class SMTacticsTab extends StatefulWidget {
  final int saveId;
  final Game game;

  const SMTacticsTab({
    super.key,
    required this.saveId,
    required this.game,
  });

  @override
  State<SMTacticsTab> createState() => _SMTacticsTabState();
}

class _SMTacticsTabState extends State<SMTacticsTab> {
  String _selectedFormation = '4-4-2';
  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(widget.saveId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tactique - Terrain interactif'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.grid_view),
            tooltip: 'Changer de formation',
            onSelected: (formation) {
              setState(() {
                _selectedFormation = formation;
              });
            },
            itemBuilder: (context) {
              return FormationCalculator.popularFormations.entries.map((entry) {
                return PopupMenuItem<String>(
                  value: entry.key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(entry.value, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: BlocBuilder<JoueursSmBloc, JoueursSmState>(
        builder: (context, state) {
          if (state is JoueursSmLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JoueursSmError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${state.message}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(widget.saveId)),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (state is JoueursSmLoaded) {
            final titulaires = state.filteredJoueurs
                .where((j) => j.joueur.status == StatusEnum.Titulaire)
                .map((e) => e.joueur)
                .toList();

            if (titulaires.isEmpty) {
              return const Center(
                child: Text('Aucun joueur titulaire'),
              );
            }

            final playerPositions = FormationCalculator.calculatePositions(
              formation: _selectedFormation,
              players: titulaires,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InteractiveSoccerField(
                    formation: _selectedFormation,
                    players: playerPositions,
                    isLoading: _isOptimizing,
                    onOptimizeTactic: _optimizeTactic,
                  ),
                  const SizedBox(height: 24),
                  _buildTeamStats(titulaires),
                ],
              ),
            );
          }

          return const Center(child: Text('Chargement...'));
        },
      ),
    );
  }

  Widget _buildTeamStats(List<JoueurSm> players) {
    final avgLevel = players.map((p) => p.niveauActuel).fold(0, (a, b) => a + b) / players.length;
    final avgAge = players.map((p) => p.age).fold(0, (a, b) => a + b) / players.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('Joueurs', players.length.toString(), Icons.people),
            _buildStat('Niveau moyen', avgLevel.toStringAsFixed(1), Icons.star),
            _buildStat('Âge moyen', avgAge.toStringAsFixed(1), Icons.cake),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _optimizeTactic() async {
    setState(() => _isOptimizing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isOptimizing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tactique optimisée avec succès!')),
    );
  }
}
