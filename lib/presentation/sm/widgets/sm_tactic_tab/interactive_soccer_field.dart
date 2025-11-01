import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_tactic_tab/player_details_dialog.dart';
import 'player_with_position.dart';
import 'player_position_widget.dart';
import 'soccer_field_widget.dart';

class InteractiveSoccerField extends StatefulWidget {
  final String formation;
  final List<PlayerWithPosition> players;
  final bool isLoading;
  final VoidCallback? onOptimizeTactic;
  final bool showHeader;

  const InteractiveSoccerField({
    super.key,
    required this.formation,
    required this.players,
    this.isLoading = false,
    this.onOptimizeTactic,
    this.showHeader = true,
  });

  @override
  State<InteractiveSoccerField> createState() => _InteractiveSoccerFieldState();
}

class _InteractiveSoccerFieldState extends State<InteractiveSoccerField> {
  int? _hoveredPlayerId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth > 600 ? 600.0 : screenWidth - 32;
    final fieldHeight = fieldWidth * 1.5;

    return Column(
      children: [
        if (widget.showHeader) _buildHeader(context),
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: fieldWidth,
            height: fieldHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(fieldWidth, fieldHeight),
                    painter: SoccerFieldPainter(),
                  ),
                  // Positionnement des joueurs
                  ...widget.players.map(
                    (p) => _buildPlayer(context, p, fieldWidth, fieldHeight),
                  ),
                  if (widget.isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  // Calcule la position absolue d'un joueur en fonction de son index et de la formation
  Offset _computePlayerOffset(int index, double width, double height) {
    // Index 0: Gardien en bas du terrain
    if (index == 0) {
      return Offset(width * 0.5 - 0, height * 0.9);
    }

    // Parse formation e.g. "4-3-3"
    final parts = widget.formation
        .split('-')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => int.tryParse(s.trim()) ?? 0)
        .toList();

    // Paramètres d'espacement
    final startY = 0.75; // ligne défensive
    final endY = 0.18;   // ligne la plus avancée
    final lines = parts.length;
    final yStep = lines > 1 ? (startY - endY) / (lines - 1) : 0.0;

    // Trouver la ligne et la colonne pour l'index (en ignorant GK)
    int remaining = index - 1; // after GK
    for (int row = 0; row < parts.length; row++) {
      final count = parts[row];
      if (remaining < count) {
        // position dans la ligne
        final xs = _xPositions(count);
        final relX = xs[remaining];
        final relY = startY - row * yStep;
        return Offset(width * relX, height * relY);
      }
      remaining -= count;
    }

    // Fallback centre
    return Offset(width * 0.5, height * 0.5);
  }

  List<double> _xPositions(int count) {
    if (count <= 1) return const [0.5];
    final list = <double>[];
    final spacing = 0.7 / (count - 1);
    for (int i = 0; i < count; i++) {
      list.add(0.15 + spacing * i);
    }
    return list;
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Formation : ${widget.formation}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: widget.isLoading ? null : widget.onOptimizeTactic,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Optimiser ma tactique'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(
      BuildContext context, PlayerWithPosition playerPos, double width, double height) {
    final isHovered = _hoveredPlayerId == playerPos.player.id;
    final idx = widget.players.indexWhere((e) => e.player.id == playerPos.player.id);
    final offset = _computePlayerOffset(idx, width, height);
    final x = offset.dx;
    final y = offset.dy;

    return Positioned(
      left: x - 25,
      top: y - 25,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredPlayerId = playerPos.player.id),
        onExit: (_) => setState(() => _hoveredPlayerId = null),
        child: GestureDetector(
          onTap: () => _showPlayerDetails(context, playerPos),
          child: PlayerPositionWidget(
            player: JoueurSm(
              id: playerPos.player.id,
              nom: playerPos.player.name,
              age: playerPos.player.age ?? 20,
              niveauActuel: playerPos.player.overall,
              potentiel: playerPos.player.overall + 5,
              montantTransfert: 1000000,
              status: StatusEnum.Titulaire,
              dureeContrat: 2028,
              salaire: 10000,
              postes: [PosteEnum.MC],
              saveId: 1,
              userId: '',
            ),
            poste: PosteEnum.MC,
            isHovered: isHovered,
          ),
        ),
      ),
    );
  }

  void _showPlayerDetails(BuildContext context, PlayerWithPosition playerPos) {
    showDialog(
      context: context,
      builder: (_) => PlayerDetailsDialog(
        player: JoueurSm(
          id: playerPos.player.id,
          nom: playerPos.player.name,
          age: playerPos.player.age ?? 20,
          niveauActuel: playerPos.player.overall,
          potentiel: playerPos.player.overall + 5,
          montantTransfert: 1000000,
          status: StatusEnum.Titulaire,
          dureeContrat: 2028,
          salaire: 10000,
          postes: [PosteEnum.MC],
          saveId: 1,
          userId: '',
        ),
        poste: PosteEnum.MC,
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _legendDot('Gardien', Colors.orange),
        _legendDot('Défenseur', Colors.blue),
        _legendDot('Milieu', Colors.green),
        _legendDot('Attaquant', Colors.red),
      ],
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
