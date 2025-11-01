import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class TacticsHeader extends StatelessWidget {
  // final JoueursSmLoaded state;
  final double width;

  const TacticsHeader({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(width);
    final totalPlayers = 23;
    final averageNiveauActuel = 87;
    final selectedFormation = '4-3-3';

    final titleSize = screenType == ScreenType.mobile
        ? 20.0
        : (screenType == ScreenType.tablet ? 24.0 : 28.0);
    
    final isMobile = screenType == ScreenType.mobile;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Optimiseur tactique',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard(context, 'Joueurs', totalPlayers.toString(), Icons.people, screenType),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                'Note',
                averageNiveauActuel.toStringAsFixed(0),
                Icons.star,
                screenType,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                'Formation',
                selectedFormation,
                Icons.grid_view,
                screenType,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Optimiseur tactique',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: 24),
        _buildStatCard(context, 'Joueurs', totalPlayers.toString(), Icons.people, screenType),
        const SizedBox(width: 16),
        _buildStatCard(
          context,
          'Note',
          averageNiveauActuel.toStringAsFixed(0),
          Icons.star,
          screenType,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          context,
          'Formation',
          selectedFormation,
          Icons.grid_view,
          screenType,
        ),
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
