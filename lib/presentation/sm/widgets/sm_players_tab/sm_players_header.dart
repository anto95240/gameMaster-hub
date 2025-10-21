import 'package:flutter/material.dart';

import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

class SMPlayersHeader extends StatelessWidget {
  final JoueursSmLoaded state;
  final double width;

  const SMPlayersHeader({super.key, required this.state, required this.width});

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(width);
    final totalPlayers = state.filteredJoueurs.length;
    final averageNiveauActuel = totalPlayers > 0
        ? state.filteredJoueurs.map((p) => p.joueur.niveauActuel).reduce((a, b) => a + b) /
            totalPlayers
        : 0;

    final titleSize = screenType == ScreenType.mobile
        ? 20.0
        : (screenType == ScreenType.tablet ? 24.0 : 28.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Gestion des Joueurs',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: 24),
        _buildStatCard(
            context, 'Joueurs', totalPlayers.toString(), Icons.people, screenType),
        const SizedBox(width: 16),
        _buildStatCard(
              context, 'Note', averageNiveauActuel.toStringAsFixed(0), Icons.star, screenType),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, String label, String value, IconData icon, ScreenType screenType) {
    final iconSize = screenType == ScreenType.mobile ? 20.0 : 24.0;
    final labelSize = screenType == ScreenType.mobile ? 11.0 : 13.0;
    final valueSize = screenType == ScreenType.mobile ? 18.0 : 22.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: labelSize,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: valueSize,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
