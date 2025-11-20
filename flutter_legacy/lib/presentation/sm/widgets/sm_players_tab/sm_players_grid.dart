import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class SMPlayersGrid extends StatelessWidget {
  final JoueursSmLoaded state;
  final double width;
  final int saveId;

  const SMPlayersGrid({
    super.key,
    required this.state,
    required this.width,
    required this.saveId,
  });

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = state.filteredJoueurs;
    if (filteredPlayers.isEmpty) {
      return const Center(child: Text('Aucun joueur trouvé'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
        final cardConstraints = ResponsiveLayout.getPlayerCardConstraints(screenType);
        final spacing = 16.0;

        final maxColumns = screenType == ScreenType.mobile
            ? 2
            : (screenType == ScreenType.tablet ? 3 : 4);

        final crossAxisCount = ResponsiveLayout.calculateOptimalColumns(
          availableWidth: constraints.maxWidth,
          constraints: cardConstraints,
          spacing: spacing,
          maxColumns: maxColumns,
        );

        final totalSpacing = spacing * (crossAxisCount - 1);
        final availableForCards = constraints.maxWidth - totalSpacing;
        final cardWidth = cardConstraints.clampWidth(availableForCards / crossAxisCount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: filteredPlayers.map((item) {
                return SizedBox(
                  width: cardWidth,
                  child: PlayerCardWidget(
                    item: item,
                    cardWidth: cardWidth,
                    onTap: () => _showPlayerDetails(context, item),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showPlayerDetails(BuildContext context, JoueurSmWithStats item) {
    showDialog(
      context: context,
      builder: (dialogContext) => PlayerDetailsDialog(
        item: item,
        saveId: saveId,
      ),
    );
  }
}
