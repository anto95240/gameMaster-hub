import 'package:flutter/material.dart'; 

import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final ScreenType screenType;
  final double? cardWidth;
  final Map<String, String> stats;
  final VoidCallback onTap;
  final Color color; // couleur directe au lieu de priority

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.screenType,
    this.cardWidth,
    required this.stats,
    required this.onTap,
    required this.color, // obligatoire maintenant
  });

  @override
  Widget build(BuildContext context) {
    final constraints = ResponsiveLayout.getGameCardConstraints(screenType);

    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;
    final isLaptop = screenType == ScreenType.laptop;

    final iconSize = isMobile ? 40.0 : (isTablet ? 48.0 : (isLaptop ? 54.0 : 60.0));
    final titleSize = isMobile ? 18.0 : (isTablet ? 20.0 : (isLaptop ? 22.0 : 24.0));
    final descriptionSize = isMobile ? 12.0 : (isTablet ? 13.0 : 14.0);
    final statLabelSize = isMobile ? 11.0 : (isTablet ? 12.0 : 13.0);
    final statValueSize = isMobile ? 16.0 : (isTablet ? 18.0 : (isLaptop ? 20.0 : 22.0));
    final padding = isMobile ? 16.0 : (isTablet ? 18.0 : (isLaptop ? 20.0 : 24.0));
    final spacing = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: constraints.minHeight,
        maxHeight: constraints.maxHeight,
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10.0 : 12.0),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: iconSize,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    _buildBadge(color, isMobile),
                  ],
                ),
                SizedBox(height: spacing),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: descriptionSize,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                SizedBox(height: spacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: stats.entries.map((entry) {
                    return Expanded(
                      child: _buildStatItem(
                        context,
                        entry.key,
                        entry.value,
                        statLabelSize,
                        statValueSize,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.0 : 10.0,
        vertical: isMobile ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.circle, size: isMobile ? 12 : 14, color: color),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    double labelSize,
    double valueSize,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: labelSize,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
