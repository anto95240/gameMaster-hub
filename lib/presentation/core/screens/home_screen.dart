import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/presentation/core/blocs/game/game_bloc.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/core/widgets/custom_app_bar.dart';
import 'package:gamemaster_hub/presentation/core/widgets/game_card.dart';

IconData getIconFromName(String? iconName) {
  switch (iconName) {
    case 'sports_soccer':
      return Icons.sports_soccer;
    case 'casino':
      return Icons.casino;
    case 'stadium':
      return Icons.stadium;
    case 'sports_esports':
      return Icons.sports_esports;
    case 'videogame_asset':
      return Icons.videogame_asset;
    case 'table_chart':
      return Icons.table_chart;
    default:
      return Icons.videogame_asset;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType =
            ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);

        return Scaffold(
          appBar: CustomAppBar(
            title: 'GameMaster Hub',
            isHomePage: true,
            showLogo: true,
            onSync: () {
              context.read<GameBloc>().add(LoadGames());
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildWelcomeSection(context, screenType),
                const SizedBox(height: 32),
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
                  fontSize:
                      isMobile ? 28 : (isTablet ? 36 : (isLaptop ? 42 : 48)),
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
        if (state is GamesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GamesError) {
          return Center(child: Text('Erreur : ${state.message}'));
        }

        if (state is GamesLoaded) {
          final games = state.games;
          final screenType =
              ResponsiveLayout.getScreenTypeFromWidth(width);
          final cardConstraints =
              ResponsiveLayout.getGameCardConstraints(screenType);
          final spacing = screenType == ScreenType.mobile ? 16.0 : 24.0;
          final crossAxisCount = ResponsiveLayout.calculateOptimalColumns(
            availableWidth: width,
            constraints: cardConstraints,
            spacing: spacing,
            maxColumns: 3,
          );

          final totalSpacing = spacing * (crossAxisCount - 1);
          final availableForCards = width - totalSpacing;
          final cardWidth =
              cardConstraints.clampWidth(availableForCards / crossAxisCount);

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: games.map((game) {
              final icon = getIconFromName(game.icon);
              final route = game.route ?? '/saves/${game.gameId}';

              return SizedBox(
                width: cardWidth,
                child: GameCard(
                  title: game.name,
                  description: game.description ?? '',
                  icon: icon,
                  screenType: screenType,
                  cardWidth: cardWidth,
                  stats: {
                    'Saves': '${game.savesCount}',
                  },
                  onTap: () {
                    if (route.startsWith('/')) {
                      context.go(route, extra: game);
                    } else {
                      context.go('/$route', extra: game);
                    }
                  },
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
