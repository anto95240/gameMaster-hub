import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'player_with_position.dart';

/// Widget d'affichage d’un joueur sur le terrain
class PlayerPositionWidget extends StatelessWidget {
  final JoueurSm player;
  final PosteEnum poste;
  final String? role;
  final bool isHovered;

  const PlayerPositionWidget({
    super.key,
    required this.player,
    required this.poste,
    this.role,
    this.isHovered = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = getPositionColor(poste.name);
    final size = isHovered ? 56.0 : 50.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: isHovered ? 3 : 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isHovered ? 0.4 : 0.3),
                  blurRadius: isHovered ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    poste.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    player.niveauActuel.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isHovered)
            Positioned(
              bottom: -20,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  player.nom,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
