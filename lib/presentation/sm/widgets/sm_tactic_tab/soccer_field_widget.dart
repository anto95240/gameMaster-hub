import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_tactic_tab/player_with_position.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_tactic_tab/mobile_player_bottom_sheet.dart';

class SoccerFieldWidget extends StatefulWidget {
  final List<PlayerWithPosition> players;
  final String formation;
  final VoidCallback? onOptimize;
  final Function(PlayerWithPosition)? onPlayerTap;

  const SoccerFieldWidget({
    super.key,
    required this.players,
    required this.formation,
    this.onOptimize,
    this.onPlayerTap,
  });

  @override
  State<SoccerFieldWidget> createState() => _SoccerFieldWidgetState();
}

class _SoccerFieldWidgetState extends State<SoccerFieldWidget> {
  PlayerWithPosition? _hoveredPlayer;
  PlayerWithPosition? _selectedPlayer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: AspectRatio(
                  aspectRatio: 0.68,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth > 800 ? 600 : constraints.maxWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(painter: SoccerFieldPainter(), size: Size.infinite),
                        // ⬇️ plus besoin de .toList() dans le spread
                        ...widget.players.map((playerPos) {
                          return _buildPlayer(context, playerPos, constraints);
                        }),
                        if (_hoveredPlayer != null || _selectedPlayer != null)
                          _buildPlayerDetails(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3A) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Formation: ${widget.formation}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${widget.players.length} joueurs positionnés', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          ]),
        ],
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, PlayerWithPosition playerPos, BoxConstraints constraints) {
    final position = _getPlayerPosition(playerPos.position, constraints);
    final color = getPositionColor(playerPos.position);
    final isHovered = _hoveredPlayer?.player.id == playerPos.player.id;
    final isSelected = _selectedPlayer?.player.id == playerPos.player.id;
    final isHighlighted = isHovered || isSelected;

    return Positioned(
      left: position.dx - (isHighlighted ? 32 : 28),
      top: position.dy - (isHighlighted ? 32 : 28),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredPlayer = playerPos),
        onExit: (_) => setState(() => _hoveredPlayer = null),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedPlayer = _selectedPlayer?.player.id == playerPos.player.id ? null : playerPos;
            });
            widget.onPlayerTap?.call(playerPos);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isHighlighted ? 64 : 56,
            height: isHighlighted ? 64 : 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isHighlighted ? Colors.white : Colors.black,
                width: isHighlighted ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: isHighlighted ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  playerPos.position,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHighlighted ? 12 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${playerPos.player.overall}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHighlighted ? 14 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerDetails(BuildContext context) {
    final player = (_selectedPlayer ?? _hoveredPlayer)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile && _selectedPlayer != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MobilePlayerBottomSheet.show(
          context,
          player,
          onViewDetails: () => widget.onPlayerTap?.call(player),
        );
        setState(() => _selectedPlayer = null);
      });
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C3A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: getPositionColor(player.position), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    player.position,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(player.player.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('Note: ${player.player.overall}', style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
            ]),
            const Divider(height: 24),
            _buildStatRow('Âge', '${player.player.age ?? "N/A"}'),
            _buildStatRow('Poste préféré', player.player.preferredPosition ?? 'N/A'),
            if (player.player.pace != null) _buildStatRow('Vitesse', '${player.player.pace}'),
            if (player.player.shooting != null) _buildStatRow('Tir', '${player.player.shooting}'),
            if (player.player.passing != null) _buildStatRow('Passes', '${player.player.passing}'),
            if (player.player.dribbling != null) _buildStatRow('Dribble', '${player.player.dribbling}'),
            if (player.player.defending != null) _buildStatRow('Défense', '${player.player.defending}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }

  Offset _getPlayerPosition(String position, BoxConstraints constraints) {
    final width = constraints.maxWidth > 800 ? 600.0 : constraints.maxWidth;
    final height = width / 0.68;

    final positions = <String, Offset>{
      'GK': const Offset(0.5, 0.95),
      'LB': const Offset(0.15, 0.80),
      'LCB': const Offset(0.35, 0.80),
      'CB': const Offset(0.5, 0.80),
      'RCB': const Offset(0.65, 0.80),
      'RB': const Offset(0.85, 0.80),
      'LWB': const Offset(0.10, 0.75),
      'RWB': const Offset(0.90, 0.75),
      'LDM': const Offset(0.35, 0.60),
      'CDM': const Offset(0.5, 0.60),
      'RDM': const Offset(0.65, 0.60),
      'LCM': const Offset(0.35, 0.50),
      'CM': const Offset(0.5, 0.50),
      'RCM': const Offset(0.65, 0.50),
      'LM': const Offset(0.15, 0.50),
      'RM': const Offset(0.85, 0.50),
      'LAM': const Offset(0.35, 0.35),
      'CAM': const Offset(0.5, 0.35),
      'RAM': const Offset(0.65, 0.35),
      'LW': const Offset(0.20, 0.20),
      'LF': const Offset(0.35, 0.20),
      'CF': const Offset(0.5, 0.20),
      'ST': const Offset(0.5, 0.15),
      'RF': const Offset(0.65, 0.20),
      'RW': const Offset(0.80, 0.20),
    };

    final relativePos = positions[position] ?? const Offset(0.5, 0.5);
    return Offset(relativePos.dx * width, relativePos.dy * height);
  }
}

class SoccerFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2D8B3C)..style = PaintingStyle.fill;
    final linePaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.0;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), linePaint);

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint);

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.12, linePaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3, Paint()..color = Colors.white);

    final penaltyBoxWidth = size.width * 0.6;
    final penaltyBoxHeight = size.height * 0.15;
    canvas.drawRect(
      Rect.fromLTWH((size.width - penaltyBoxWidth) / 2, 0, penaltyBoxWidth, penaltyBoxHeight),
      linePaint,
    );

    final goalBoxWidth = size.width * 0.35;
    final goalBoxHeight = size.height * 0.08;
    canvas.drawRect(
      Rect.fromLTWH((size.width - goalBoxWidth) / 2, 0, goalBoxWidth, goalBoxHeight),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH((size.width - penaltyBoxWidth) / 2, size.height - penaltyBoxHeight, penaltyBoxWidth, penaltyBoxHeight),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH((size.width - goalBoxWidth) / 2, size.height - goalBoxHeight, goalBoxWidth, goalBoxHeight),
      linePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, penaltyBoxHeight), radius: size.width * 0.12),
      3.14,
      3.14,
      false,
      linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height - penaltyBoxHeight), radius: size.width * 0.12),
      0,
      3.14,
      false,
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
