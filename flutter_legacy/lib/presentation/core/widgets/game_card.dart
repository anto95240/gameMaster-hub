import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final ScreenType screenType;
  final double? cardWidth;
  final Map<String, String> stats;
  final VoidCallback onTap;
  final Color color;

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.screenType,
    this.cardWidth,
    required this.stats,
    required this.onTap,
    required this.color,
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
    final statLabelSize = isMobile ? 10.0 : (isTablet ? 11.0 : 12.0);
    final statValueSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
    final padding = isMobile ? 16.0 : (isTablet ? 18.0 : (isLaptop ? 20.0 : 24.0));
    final spacing = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);

    double statSquareSize = (cardWidth ?? constraints.maxWidth) / 5;
    if (statSquareSize > 60) statSquareSize = 60;
    if (statSquareSize < 40) statSquareSize = 40;

    return SizedBox(
      width: cardWidth ?? constraints.maxWidth,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      child: Icon(icon, size: iconSize, color: color),
                    ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: stats.entries.map((entry) {
                    return Container(
                      width: statSquareSize,
                      height: statSquareSize,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: statValueSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: statLabelSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
}
