import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class FieldPlayerCard extends StatelessWidget {
  final JoueurSmWithStats player;
  final RoleModeleSm role;
  final VoidCallback onTap;

  const FieldPlayerCard({
    super.key,
    required this.player,
    required this.role,
    required this.onTap,
  });

  Color _getBarColor() {
    final joueur = player.joueur;
    final rolePoste = role.poste; // Ex: "DC"

    if (joueur.postes.isEmpty) return Colors.red;

    // Poste principal (ex: 'DG')
    final postePrincipal = joueur.postes.first.name;

    if (rolePoste == postePrincipal) {
      return Colors.green; // Vert si c'est le poste principal
    }

    // Vérifie si c'est un poste secondaire
    for (var i = 1; i < joueur.postes.length; i++) {
      if (joueur.postes[i].name == rolePoste) {
        return Colors.orange; // Orange si c'est un poste secondaire
      }
    }

    return Colors.red; // Rouge si pas compatible
  }

  @override
  Widget build(BuildContext context) {
    final joueur = player.joueur;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ligne Note + Nom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: getRatingColor(joueur.niveauActuel).withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    joueur.niveauActuel.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    role.poste, // Affiche le poste assigné (ex: DC)
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Nom du joueur
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Text(
                joueur.nom,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            // Barre de couleur
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _getBarColor(),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}