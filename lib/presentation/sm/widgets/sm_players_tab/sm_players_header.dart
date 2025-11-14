import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class SMPlayersHeader extends StatelessWidget {
  final JoueursSmLoaded state;
  final double width;
  final int currentTabIndex;
  final String? selectedFormation;

  const SMPlayersHeader({
    super.key,
    required this.state,
    required this.width,
    required this.currentTabIndex,
    this.selectedFormation,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(width);
    final totalPlayers = state.filteredJoueurs.length;
    final averageNiveauActuel = totalPlayers > 0
        ? state.filteredJoueurs
                .map((p) => p.joueur.niveauActuel)
                .reduce((a, b) => a + b) /
            totalPlayers
        : 0;

    final titleSize = screenType == ScreenType.mobile
        ? 20.0
        : (screenType == ScreenType.tablet ? 24.0 : 28.0);
    final isMobile = screenType == ScreenType.mobile;

    String title;
    List<Widget> statCards = [];

    switch (currentTabIndex) {
      case 0:
        title = "Gestion des joueurs";
        statCards = [
          _buildStatCard(context, 'Joueurs', totalPlayers.toString(),
              Icons.people, screenType),
          _buildStatCard(context, 'Note',
              averageNiveauActuel.toStringAsFixed(0), Icons.star, screenType),
        ];
        break;

      case 1:
        title = "Tactique de l’équipe";
        statCards = [
          _buildStatCard(context, 'Joueurs', totalPlayers.toString(),
              Icons.people, screenType),
          _buildStatCard(
            context,
            'Tactique',
            selectedFormation ?? 'Aucune',
            Icons.grid_view,
            screenType,
          ),

          _buildStatCard(context, 'Note',
              averageNiveauActuel.toStringAsFixed(0), Icons.star, screenType),
        ];
        break;

      case 2:
        title = "Analyse d’équipe";
        statCards = [
          _buildStatCard(context, 'Joueurs', totalPlayers.toString(),
              Icons.people, screenType),
          _buildStatCard(context, 'Note',
              averageNiveauActuel.toStringAsFixed(0), Icons.star, screenType),
        ];
        break;

      default:
        title = "Gestion";
    }

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: statCards,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: 24),
        ...statCards.map((c) => Padding(
              padding: const EdgeInsets.only(left: 16),
              child: c,
            )),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, ScreenType screenType) {
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
            mainAxisSize: MainAxisSize.min,
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