import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gamemaster_hub/presentation/core/blocs/game/game_bloc.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/core/widgets/custom_app_bar.dart';
import 'package:gamemaster_hub/presentation/core/widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
        final isMobile = screenType == ScreenType.mobile;
        final horizontalPadding = ResponsiveLayout.getHorizontalPadding(constraints.maxWidth);
        final verticalPadding = ResponsiveLayout.getVerticalPadding(constraints.maxWidth);

        final isMobileOrTablet = screenType == ScreenType.mobile || screenType == ScreenType.tablet;
        double screenWidth = constraints.maxWidth;
        double fontSize = screenWidth < 400
            ? 14
            : screenWidth < 600
                ? 16
                : 18;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'GameMaster Hub',
            isHomePage: true,
            isMobile: isMobileOrTablet,
            mobileTitleSize: fontSize,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              children: [
                _buildWelcomeSection(context, screenType),
                SizedBox(height: isMobile ? 32 : 48),
                _buildGamesGrid(context, constraints.maxWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ScreenType screenType) {
    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;
    final isLaptop = screenType == ScreenType.laptop;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Bienvenue dans GameMaster Hub',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: isMobile ? 28 : (isTablet ? 36 : (isLaptop ? 42 : 48)),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Choisissez votre jeu et optimisez vos performances',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: isMobile ? 14 : (isTablet ? 16 : 18),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGamesGrid(BuildContext context, double width) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is GamesLoading) return const Center(child: CircularProgressIndicator());
        if (state is GamesError) return Center(child: Text('Erreur: ${state.message}'));
        if (state is GamesLoaded) {
          final games = state.games;
          final screenType = ResponsiveLayout.getScreenTypeFromWidth(width);
          final cardConstraints = ResponsiveLayout.getGameCardConstraints(screenType);
          final spacing = screenType == ScreenType.mobile ? 16.0 : 24.0;
          final crossAxisCount = ResponsiveLayout.calculateOptimalColumns(
            availableWidth: width,
            constraints: cardConstraints,
            spacing: spacing,
            maxColumns: 3,
          );
          final totalSpacing = spacing * (crossAxisCount - 1);
          final availableForCards = width - totalSpacing;
          final cardWidth = cardConstraints.clampWidth(availableForCards / crossAxisCount);

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: games.map((game) {
              return SizedBox(
                width: cardWidth,
                child: GameCard(
                  title: game.name,
                  description: game.description ?? '',
                  icon: Icons.videogame_asset,
                  screenType: screenType,
                  cardWidth: cardWidth,
                  stats: {},
                  onTap: () => context.go('/saves/${game.gameId}', extra: game),
                  color: Colors.green,
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }
}
