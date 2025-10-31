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

  const InteractiveSoccerField({
    super.key,
    required this.formation,
    required this.players,
    this.isLoading = false,
    this.onOptimizeTactic,
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
        _buildHeader(context),
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

    // Position selon les coordonnées relatives (si disponibles)
    final x = width * 0.5; // centré horizontalement (tu peux adapter)
    final y = height * 0.5; // centré verticalement (à adapter si formation gérée)

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
