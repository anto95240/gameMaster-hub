import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class FieldPlayerCard extends StatelessWidget {
  final JoueurSmWithStats player;
  final RoleModeleSm role;
  final VoidCallback onTap;
  final ScreenType screenType;

  static const Color _bgSecondaryDark = Color(0xFF2C2C3A);
  static const Color _accentPrimaryLight = Color(0xFF0891B2); 

  const FieldPlayerCard({
    super.key,
    required this.player,
    required this.role,
    required this.onTap,
    required this.screenType,
  });

  Color _getBackgroundColor() {
    final joueur = player.joueur;
    final rolePoste = role.poste; 

    if (joueur.postes.isEmpty) return Colors.red[700]!;

    final postePrincipal = joueur.postes.first.name;

    if (rolePoste == postePrincipal) {
      return Colors.green[700]!;
    }

    for (var i = 1; i < joueur.postes.length; i++) {
      if (joueur.postes[i].name == rolePoste) {
        return _accentPrimaryLight; 
      }
    }

    return Colors.red[700]!;
  }

  Color _getNoteColor() {
    return getRatingColor(player.joueur.niveauActuel);
  }

  @override
  Widget build(BuildContext context) {
    final joueur = player.joueur;

    final double noteSize = switch (screenType) {
      ScreenType.mobile => 10.0,
      ScreenType.tablet => 12.0,
      _ => 14.0, 
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

    final double horizontalPadding = switch (screenType) {
      ScreenType.mobile => 4.0,
      ScreenType.tablet => 5.0,
      _ => 6.0, 
    };
    
    final double verticalPadding = switch (screenType) {
      ScreenType.mobile => 3.0,
      _ => 4.0,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent, 
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: _bgSecondaryDark.withOpacity(0.7),
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      joueur.niveauActuel.toString(),
                      style: TextStyle(
                        color: _getNoteColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: noteSize,
                      ),
                    ),
                    Text(
                      role.poste, 
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: posteSize,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                ),
                child: Text(
                  joueur.nom,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: nameSize,
                    fontWeight: FontWeight.bold, 
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