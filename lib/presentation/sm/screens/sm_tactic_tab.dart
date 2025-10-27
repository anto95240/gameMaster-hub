import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_tactic_tab/player_with_position.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_tactic_tab/soccer_field_widget.dart';

class SMTacticTab extends StatefulWidget {
  final int saveId;
  final Game game;

  const SMTacticTab({
    super.key,
    required this.saveId,
    required this.game,
  });

  @override
  State<SMTacticTab> createState() => _SMTacticTabState();
}

class _SMTacticTabState extends State<SMTacticTab> {
  List<PlayerWithPosition> _optimizedFormation = [];
  String _currentFormation = '4-3-3';
  bool _isOptimizing = false;
  String? _errorMessage;
  int _playersCount = 0;

  final List<String> _availableFormations = const [
    '4-3-3',
    '4-4-2',
    '3-5-2',
    '4-2-3-1',
    '3-4-3',
    '4-1-4-1',
    '5-3-2',
    '4-5-1',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentFormation();
  }

  Future<void> _loadCurrentFormation() async {
    await _optimizeFormation();
  }

  Future<void> _optimizeFormation() async {
    setState(() {
      _isOptimizing = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      final joueurs = await supabase
          .from('joueur_sm')
          .select('id, nom, age, niveau_actuel, postes, save_id')
          .eq('save_id', widget.saveId);

      final statsRows = await supabase
          .from('stats_joueur_sm')
          .select('joueur_id, vitesse, finition, passes, dribble, tacles, positionnement, force')
          .eq('save_id', widget.saveId);

      if (!mounted) return;

      final statsByPlayerId = <int, Map<String, dynamic>>{};
      for (final s in (statsRows as List)) {
        statsByPlayerId[s['joueur_id'] as int] = s as Map<String, dynamic>;
      }

      final players = <TacticPlayer>[];
      for (final j in (joueurs as List)) {
        final id = j['id'] as int;
        final nom = (j['nom'] as String?) ?? 'Inconnu';
        final age = j['age'] as int?;
        final overall = (j['niveau_actuel'] as int?) ?? 50;
        final postes = (j['postes'] as List?)?.cast<String>() ?? const [];
        final preferred = postes.isNotEmpty ? postes.first : null;

        final st = statsByPlayerId[id];

        final pace = (st?['vitesse'] as int?);
        final shooting = (st?['finition'] as int?);
        final passing = (st?['passes'] as int?);
        final dribbling = (st?['dribble'] as int?);
        final defending = _avgInts((st?['tacles'] as int?), (st?['positionnement'] as int?));
        final physical = (st?['force'] as int?);

        players.add(TacticPlayer(
          id: id,
          name: nom,
          age: age,
          overall: overall,
          preferredPosition: preferred,
          pace: pace,
          shooting: shooting,
          passing: passing,
          dribbling: dribbling,
          defending: defending,
          physical: physical,
        ));
      }

      final optimized = _simulateOptimization(players, _currentFormation);

      setState(() {
        _playersCount = players.length;
        _optimizedFormation = optimized;
        _isOptimizing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur lors de l\'optimisation: $e';
        _isOptimizing = false;
      });
    }
  }

  int? _avgInts(int? a, int? b) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return ((a + b) / 2).round();
  }

  // --- Algorithme temporaire à remplacer par [SM-06] ---
  List<PlayerWithPosition> _simulateOptimization(
    List<TacticPlayer> players,
    String formation,
  ) {
    final positions = _getPositionsForFormation(formation);
    final result = <PlayerWithPosition>[];

    final sortedPlayers = List<TacticPlayer>.from(players)
      ..sort((a, b) => b.overall.compareTo(a.overall));

    for (int i = 0; i < positions.length && i < sortedPlayers.length; i++) {
      final p = sortedPlayers[i];
      result.add(PlayerWithPosition(
        player: p,
        position: positions[i],
        compatibility: _calculateCompatibility(p, positions[i]),
      ));
    }
    return result;
  }

  List<String> _getPositionsForFormation(String formation) {
    final positions = <String>['GK'];
    switch (formation) {
      case '4-3-3':
        positions.addAll(['LB', 'LCB', 'RCB', 'RB']);
        positions.addAll(['LCM', 'CM', 'RCM']);
        positions.addAll(['LW', 'ST', 'RW']);
        break;
      case '4-4-2':
        positions.addAll(['LB', 'LCB', 'RCB', 'RB']);
        positions.addAll(['LM', 'LCM', 'RCM', 'RM']);
        positions.addAll(['ST', 'ST']);
        break;
      case '3-5-2':
        positions.addAll(['LCB', 'CB', 'RCB']);
        positions.addAll(['LWB', 'LCM', 'CM', 'RCM', 'RWB']);
        positions.addAll(['ST', 'ST']);
        break;
      case '4-2-3-1':
        positions.addAll(['LB', 'LCB', 'RCB', 'RB']);
        positions.addAll(['LDM', 'RDM']);
        positions.addAll(['LAM', 'CAM', 'RAM']);
        positions.add('ST');
        break;
      case '3-4-3':
        positions.addAll(['LCB', 'CB', 'RCB']);
        positions.addAll(['LM', 'LCM', 'RCM', 'RM']);
        positions.addAll(['LW', 'ST', 'RW']);
        break;
      case '4-1-4-1':
        positions.addAll(['LB', 'LCB', 'RCB', 'RB']);
        positions.add('CDM');
        positions.addAll(['LM', 'LCM', 'RCM', 'RM']);
        positions.add('ST');
        break;
      case '5-3-2':
        positions.addAll(['LWB', 'LCB', 'CB', 'RCB', 'RWB']);
        positions.addAll(['LCM', 'CM', 'RCM']);
        positions.addAll(['ST', 'ST']);
        break;
      case '4-5-1':
        positions.addAll(['LB', 'LCB', 'RCB', 'RB']);
        positions.addAll(['LM', 'LCM', 'CM', 'RCM', 'RM']);
        positions.add('ST');
        break;
      default:
        positions.addAll(['LB', 'LCB', 'RCB', 'RB']);
        positions.addAll(['LCM', 'CM', 'RCM']);
        positions.addAll(['LW', 'ST', 'RW']);
    }
    return positions;
  }

  double _calculateCompatibility(TacticPlayer player, String position) {
    if (player.preferredPosition == position) return 100.0;
    return min(95, (player.overall * 0.8)).toDouble();
  }
  // --- Fin algo temporaire ---

  @override
  Widget build(BuildContext context) {
    if (_isOptimizing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Optimisation de la formation en cours...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            _GradientButton(
              text: 'Réessayer',
              onTap: _optimizeFormation,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre + chips à droite (formation / joueurs)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Optimiseur de Tactique',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      _StatChip(
                        title: 'FORMATION',
                        value: _currentFormation,
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        title: 'JOUEURS',
                        value: '$_playersCount',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Panneaux supérieurs (Formations, Styles, Rôles) + bouton Optimiser
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _CardPanel(title: 'Formations', child: _formationsChips())),
                        const SizedBox(width: 16),
                        Expanded(flex: 5, child: const _CardPanel(title: 'Styles', child: SizedBox(height: 120))),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: const _CardPanel(title: 'Rôles', child: SizedBox(height: 120))),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 140,
                          child: _GradientButton(
                            text: 'Optimiser',
                            onTap: _optimizeFormation,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CardPanel(title: 'Formations', child: _formationsChips()),
                        const SizedBox(height: 12),
                        const _CardPanel(title: 'Styles', child: SizedBox(height: 120)),
                        const SizedBox(height: 12),
                        const _CardPanel(title: 'Rôles', child: SizedBox(height: 120)),
                        const SizedBox(height: 12),
                        _GradientButton(text: 'Optimiser', onTap: _optimizeFormation),
                      ],
                    ),

              const SizedBox(height: 24),

              // Grand panneau terrain (vert dans la maquette)
              _BigFieldCard(
                child: _optimizedFormation.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sports_soccer, size: 64, color: Colors.black54),
                            const SizedBox(height: 8),
                            const Text('Aucune formation disponible'),
                            const SizedBox(height: 12),
                            _GradientButton(text: 'Optimiser', onTap: _optimizeFormation),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: isWide ? 520 : 420,
                        child: SoccerFieldWidget(
                          players: _optimizedFormation,
                          formation: _currentFormation,
                          onOptimize: _optimizeFormation,
                          onPlayerTap: _showPlayerDetailDialog,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _formationsChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: _availableFormations.map((f) {
          final isSelected = f == _currentFormation;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (s) {
                if (s) {
                  setState(() => _currentFormation = f);
                  _optimizeFormation();
                }
              },
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showPlayerDetailDialog(PlayerWithPosition playerPos) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(playerPos.player.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Position', playerPos.position),
            _buildDetailRow('Note globale', '${playerPos.player.overall}'),
            _buildDetailRow('Compatibilité', '${playerPos.compatibility.toStringAsFixed(1)}%'),
            _buildDetailRow('Âge', '${playerPos.player.age ?? "N/A"}'),
            _buildDetailRow('Poste préféré', playerPos.player.preferredPosition ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

/* -------------------------- UI helpers (look & feel) ----------------------- */

class _CardPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2F2F3A) : const Color(0xFFE9EAEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              )),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String title;
  final String value;

  const _StatChip({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2F2F3A) : const Color(0xFFE9EAEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black54)),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GradientButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF58D3F7), Color(0xFFFFD966)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _BigFieldCard extends StatelessWidget {
  final Widget child;

  const _BigFieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2F2F3A) : const Color(0xFFE9EAEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4C9A3B), // vert “terrain” de la maquette
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
