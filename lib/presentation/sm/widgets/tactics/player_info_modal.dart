import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class PlayerInfoModal extends StatelessWidget {
  final JoueurSmWithStats? player;
  final RoleModeleSm? role;
  final JoueursSmState allPlayers;
  final String basePoste;

  const PlayerInfoModal({
    Key? key,
    this.player,
    this.role,
    required this.allPlayers,
    required this.basePoste,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);

    // Données dynamiques
    final String nom = player?.joueur.nom ?? 'Poste non assigné';
    final String poste = player?.joueur.postes.map((p) => p.name).join('/') ?? basePoste;
    final String age = player?.joueur.age.toString() ?? '-';
    final String contrat = player?.joueur.dureeContrat.toString() ?? '-';
    final String note = player?.joueur.niveauActuel.toString() ?? '-';
    final String potentiel = player?.joueur.potentiel.toString() ?? '-';
    final String roleNom = role?.role ?? 'Rôle non défini';
    final String roleDesc = role?.description ?? 'Aucun rôle optimisé n\'a été assigné pour ce poste.';


    final maxWidth = switch (screenType) {
      ScreenType.mobile => 360.0,
      ScreenType.tablet => 440.0,
      ScreenType.laptop => 480.0,
      ScreenType.laptopL => 520.0,
    };
    final avatarSize = switch (screenType) {
      ScreenType.mobile => 42.0,
      ScreenType.tablet => 50.0,
      ScreenType.laptop => 56.0,
      ScreenType.laptopL => 60.0,
    };
    final titleSize = switch (screenType) {
      ScreenType.mobile => 16.0,
      ScreenType.tablet => 17.0,
      ScreenType.laptop => 18.0,
      ScreenType.laptopL => 20.0,
    };
    final textSize = switch (screenType) {
      ScreenType.mobile => 13.0,
      ScreenType.tablet => 14.0,
      ScreenType.laptop => 15.0,
      ScreenType.laptopL => 16.0,
    };
    
    // ✅ LA LOGIQUE DES REMPLAÇANTS ("otherOptions") A ÉTÉ SUPPRIMÉE, CE QUI CORRIGE L'ERREUR

    return Dialog(
      backgroundColor: const Color(0xFF2b2e3c),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container( // Plus besoin de scroll
        width: maxWidth,
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(minHeight: 250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Titulaire ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: player != null ? const Color(0xFF4dd0e1) : Colors.grey[700],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    nom.isNotEmpty ? nom[0] : '?',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: avatarSize * 0.45,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nom,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (player != null)
                        Text(
                          "$poste • $age ans • $contrat",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: textSize - 1,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (player != null)
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildRatingBadge(note, screenType, getRatingColor(player!.joueur.niveauActuel)),
                      _buildRatingBadge(potentiel,
                          screenType, getProgressionColor(player!.joueur.potentiel)),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(color: Color(0xFF3d4254)),
            const SizedBox(height: 14),

            // --- Section Rôle ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sports_soccer,
                    color: Colors.white38, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    roleNom,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              roleDesc,
              style: TextStyle(
                color: Colors.white60,
                fontSize: textSize - 1,
                height: 1.4,
              ),
              textAlign: TextAlign.justify,
            ),
            
            // ✅ SECTION REMPLAÇANTS SUPPRIMÉE
          ],
        ),
      ),
    );
  }

  // ✅ HELPER _buildPlayerRow SUPPRIMÉ

  static Widget _buildRatingBadge(
    String value,
    ScreenType screenType,
    Color color,
  ) {
    final double fontSize = switch (screenType) {
      ScreenType.mobile => 12,
      ScreenType.tablet => 13,
      ScreenType.laptop => 14,
      ScreenType.laptopL => 15,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}