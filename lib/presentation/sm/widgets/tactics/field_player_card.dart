// [lib/presentation/sm/widgets/tactics/field_player_card.dart]
import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
// ✅ 1. Texte réactif : Import de ResponsiveLayout
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class FieldPlayerCard extends StatelessWidget {
  final JoueurSmWithStats player;
  final RoleModeleSm role;
  final VoidCallback onTap;
  // ✅ 1. Texte réactif : Ajout de screenType
  final ScreenType screenType;

  // Couleurs du Thème Dark (pour l'harmonie)
  static const Color _bgSecondaryDark = Color(0xFF2C2C3A);
  static const Color _accentPrimaryLight = Color(0xFF0891B2); // Bleu pour poste secondaire

  const FieldPlayerCard({
    super.key,
    required this.player,
    required this.role,
    required this.onTap,
    // ✅ 1. Texte réactif : Ajout au constructeur
    required this.screenType,
  });

  // La logique pour déterminer la COULEUR DE FOND (basée sur la compatibilité)
  Color _getBackgroundColor() {
    final joueur = player.joueur;
    final rolePoste = role.poste; // Ex: "DC"

    if (joueur.postes.isEmpty) return Colors.red[700]!;

    // Poste principal (ex: 'DG')
    final postePrincipal = joueur.postes.first.name;

    if (rolePoste == postePrincipal) {
      return Colors.green[700]!; // Vert si c'est le poste principal
    }

    // Vérifie si c'est un poste secondaire
    for (var i = 1; i < joueur.postes.length; i++) {
      if (joueur.postes[i].name == rolePoste) {
        return _accentPrimaryLight; // Bleu si c'est un poste secondaire
      }
    }

    return Colors.red[700]!; // Rouge si pas compatible
  }

  // La logique pour déterminer la COULEUR DE LA NOTE (basée sur la note)
  Color _getNoteColor() {
    // Utilise la fonction globale getRatingColor de player_utils.dart
    return getRatingColor(player.joueur.niveauActuel);
  }

  @override
  Widget build(BuildContext context) {
    final joueur = player.joueur;

    // ✅ Tailles de police dynamiques
    final double noteSize = switch (screenType) {
      ScreenType.mobile => 10.0,
      ScreenType.tablet => 12.0,
      _ => 14.0, // Laptop & LaptopL
    };
    final double posteSize = switch (screenType) {
      ScreenType.mobile => 10.0,
      ScreenType.tablet => 12.0,
      _ => 13.0,
    };
    final double nameSize = switch (screenType) {
      ScreenType.mobile => 10.0,
      ScreenType.tablet => 12.0,
      _ => 13.0,
    };

    // ✅✅✅ CORRECTION : Padding dynamique pour corriger l'overflow
    final double horizontalPadding = switch (screenType) {
      ScreenType.mobile => 4.0, // Réduit de 6
      ScreenType.tablet => 5.0,
      _ => 6.0, // Défaut pour laptop
    };
    
    final double verticalPadding = switch (screenType) {
      ScreenType.mobile => 3.0, // Réduit de 4
      _ => 4.0,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        // ✅ MODIFIÉ : Fond principal transparent, avec bordure
        decoration: BoxDecoration(
          color: Colors.transparent, // Fond principal transparent
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        // ClipRRect pour que les enfants respectent le border radius
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3), // 4 - 1 (largeur bordure)
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ S'arrête juste après le contenu
            crossAxisAlignment: CrossAxisAlignment.stretch, // Étire les enfants
            children: [
              // --- PARTIE HAUTE (Note + Poste) ---
              Container(
                // ✅ MODIFIÉ : Fond semi-transparent harmonisé
                color: _bgSecondaryDark.withOpacity(0.7),
                // ✅✅✅ CORRECTION : Padding dynamique appliqué
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      joueur.niveauActuel.toString(),
                      style: TextStyle(
                        color: _getNoteColor(), // Couleur basée sur la note
                        fontWeight: FontWeight.bold,
                        // ✅ Taille dynamique
                        fontSize: noteSize,
                      ),
                    ),
                    Text(
                      role.poste, // Affiche le poste assigné (ex: DC)
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        // ✅ Taille dynamique
                        fontSize: posteSize,
                      ),
                    ),
                  ],
                ),
              ),
              // --- PARTIE BASSE (Nom du joueur) ---
              Container(
                // ✅✅✅ CORRECTION : Padding dynamique appliqué
                padding:
                    EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
                // ✅ MODIFIÉ : Couleur de fond unie basée sur la compatibilité
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                ),
                child: Text(
                  joueur.nom,
                  style: TextStyle(
                    color: Colors.white,
                    // ✅ Taille dynamique
                    fontSize: nameSize,
                    fontWeight: FontWeight.bold, // Nom en gras
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}