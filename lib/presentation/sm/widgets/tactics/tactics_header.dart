import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class TacticsHeader extends StatelessWidget {
  final double width;

  const TacticsHeader({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(width);
    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;

    final totalPlayers = 23;
    final averageNiveauActuel = 87;
    final selectedFormation = '4-3-3';

    final titleSize = switch (screenType) {
      ScreenType.mobile => 20.0,
      ScreenType.tablet => 24.0,
      ScreenType.laptop => 28.0,
      ScreenType.laptopL => 28.0,
    };

    final spacing = switch (screenType) {
      ScreenType.mobile => 10.0,
      ScreenType.tablet => 14.0,
      ScreenType.laptop => 18.0,
      ScreenType.laptopL => 20.0,
    };

    final statCards = [
      _buildStatCard(context, 'Joueurs', totalPlayers.toString(), Icons.people, screenType),
      _buildStatCard(context, 'Note', averageNiveauActuel.toStringAsFixed(0), Icons.star, screenType),
      _buildStatCard(context, 'Formation', selectedFormation, Icons.grid_view, screenType),
    ];

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
          SizedBox(height: spacing),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: statCards,
          ),
        ],
      );
    }

    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Optimiseur tactique',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: spacing),
          Wrap(
            spacing: 12,
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
          flex: 2,
          child: Text(
            'Optimiseur tactique',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const Spacer(),
        ...statCards
            .map((card) => Padding(
                  padding: EdgeInsets.only(left: spacing),
                  child: card,
                ))
            .toList(),
      ],
    );
  }
  Widget _buildStatCard(
      BuildContext context, String label, String value, IconData icon, ScreenType screenType) {
    final iconSize = switch (screenType) {
      ScreenType.mobile => 18.0,
      ScreenType.tablet => 22.0,
      ScreenType.laptop => 24.0,
      ScreenType.laptopL => 26.0,
    };

    final labelSize = switch (screenType) {
      ScreenType.mobile => 11.0,
      ScreenType.tablet => 12.0,
      ScreenType.laptop => 13.0,
      ScreenType.laptopL => 14.0,
    };

    final valueSize = switch (screenType) {
      ScreenType.mobile => 18.0,
      ScreenType.tablet => 20.0,
      ScreenType.laptop => 22.0,
      ScreenType.laptopL => 24.0,
    };

    final paddingH = switch (screenType) {
      ScreenType.mobile => 12.0,
      ScreenType.tablet => 14.0,
      ScreenType.laptop => 16.0,
      ScreenType.laptopL => 18.0,
    };

    final paddingV = switch (screenType) {
      ScreenType.mobile => 8.0,
      ScreenType.tablet => 10.0,
      ScreenType.laptop => 12.0,
      ScreenType.laptopL => 14.0,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
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
