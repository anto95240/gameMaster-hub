import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';

class PlayerAvatar extends StatelessWidget {
  final JoueurSm joueur;
  const PlayerAvatar({super.key, required this.joueur});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    // 🔹 Taille du cercle et de la police selon l’écran
    final double avatarSize = isMobile ? 48 : (isTablet ? 64 : 80);
    final double fontSize = isMobile ? 20 : (isTablet ? 26 : 32);

    final initial = joueur.nom.isNotEmpty ? joueur.nom[0].toUpperCase() : '?';

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white24
              : Colors.black12,
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0A0F1E)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
