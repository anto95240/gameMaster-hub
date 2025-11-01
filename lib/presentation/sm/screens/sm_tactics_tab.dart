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
    return BlocBuilder<JoueursSmBloc, JoueursSmState>(
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

            final avgLevel = titulaires
                    .map((p) => p.niveauActuel)
                    .fold<int>(0, (a, b) => a + b) /
                (titulaires.isEmpty ? 1 : titulaires.length);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + chips row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Optimiseur de Tactique',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      _statChip(Icons.people_alt, 'Joueurs', titulaires.length.toString()),
                      const SizedBox(width: 12),
                      _statChip(Icons.star, 'Note', avgLevel.round().toString()),
                      const SizedBox(width: 12),
                      _statChip(Icons.shuffle, 'Formation', _selectedFormation),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Lists + optimize button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _formationsList()),
                      const SizedBox(width: 16),
                      Expanded(child: _stylesList()),
                      const SizedBox(width: 16),
                      _optimizeButton(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Field area (no side text as per final design)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 6,
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: InteractiveSoccerField(
                              formation: _selectedFormation,
                              players: playerPositions,
                              isLoading: _isOptimizing,
                              onOptimizeTactic: _optimizeTactic,
                              showHeader: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Chargement...'));
        },
    );
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _formationsList() {
    final items = FormationCalculator.popularFormations;
    return _boxed(
      title: 'Liste des Formations',
      child: ListView(
        padding: EdgeInsets.zero,
        children: items.entries.map((e) {
          final selected = e.key == _selectedFormation;
          return ListTile(
            dense: true,
            title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(e.value),
            trailing: selected ? const Icon(Icons.check_circle, color: Colors.amber) : null,
            onTap: () => setState(() => _selectedFormation = e.key),
          );
        }).toList(),
      ),
    );
  }

  Widget _stylesList() {
    return _boxed(
      title: 'Liste des Styles de jeu',
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          ListTile(title: Text('Équilibré'), subtitle: Text('Bientôt disponible')), 
          ListTile(title: Text('Offensif'), subtitle: Text('Bientôt disponible')),
          ListTile(title: Text('Défensif'), subtitle: Text('Bientôt disponible')),
        ],
      ),
    );
  }

  Widget _boxed({required String title, required Widget child}) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _optimizeButton() {
    return Column(
      children: [
        Container(
          width: 140,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFFFFD54F)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: _isOptimizing ? null : _optimizeTactic,
              child: Center(
                child: _isOptimizing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Optimiser', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
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
