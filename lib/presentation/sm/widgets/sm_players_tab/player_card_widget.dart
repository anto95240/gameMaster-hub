import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

class PlayerCardWidget extends StatelessWidget {
  final JoueurSmWithStats item;
  final VoidCallback onTap;
  final double? cardWidth;

  const PlayerCardWidget({
    super.key,
    required this.item,
    required this.onTap,
    this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final joueur = item.joueur;
    final width = cardWidth ?? MediaQuery.of(context).size.width;
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(width);
    final constraints = ResponsiveLayout.getPlayerCardConstraints(screenType);

    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;
    final isLaptop = screenType == ScreenType.laptop;

    final avatarRadius =
        isMobile ? 20.0 : (isTablet ? 24.0 : (isLaptop ? 26.0 : 28.0));
    final titleSize =
        isMobile ? 14.0 : (isTablet ? 15.0 : (isLaptop ? 16.0 : 17.0));
    final subtitleSize = isMobile ? 11.0 : (isTablet ? 12.0 : 13.0);
    final badgeTextSize =
        isMobile ? 12.0 : (isTablet ? 13.0 : (isLaptop ? 14.0 : 15.0));
    final padding =
        isMobile ? 12.0 : (isTablet ? 14.0 : (isLaptop ? 16.0 : 18.0));
    final spacing = isMobile ? 8.0 : (isTablet ? 10.0 : 12.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: constraints.minHeight,
        maxHeight: constraints.maxHeight,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      child: Text(
                        joueur.nom[0],
                        style: TextStyle(
                          color: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? const Color(0xFF0A0F1E)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: avatarRadius * 0.7,
                        ),
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            joueur.nom,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${joueur.postes.map((e) => e.name).join("/")} • \n${joueur.age} ans • ${joueur.dureeContrat}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: subtitleSize),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // 🔹 Badge note
                    _buildRatingBadge(
                      context,
                      joueur.niveauActuel,
                      badgeTextSize,
                      _getRatingColor(joueur.niveauActuel),
                    ),
                    SizedBox(width: spacing * 0.5),
                    // 🔹 Badge potentiel
                    _buildRatingBadge(
                      context,
                      joueur.potentiel,
                      badgeTextSize,
                      _getPotentialColor(joueur.potentiel),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        joueur.status.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: subtitleSize),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '€${joueur.montantTransfert}M',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Badge affichant note / potentiel
  Widget _buildRatingBadge(
      BuildContext context, int rating, double fontSize, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.5,
        vertical: fontSize * 0.25,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        rating.toString(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  /// 🔸 Couleur de la note actuelle
  Color _getRatingColor(int rating) {
    if (rating >= 85) return Colors.green;
    if (rating >= 80) return Colors.blue;
    return Colors.orange;
  }

  /// 🔸 Couleur du potentiel (légèrement différente pour contraste)
  Color _getPotentialColor(int potential) {
    if (potential >= 90) return Colors.lightGreen;
    if (potential >= 80) return Colors.cyan;
    return Colors.amber;
  }
}
