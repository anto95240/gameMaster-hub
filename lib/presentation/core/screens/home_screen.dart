import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/core/blocs/game/game_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/theme/theme_bloc.dart';
import '../widgets/game_card.dart';
import '../utils/responsive_layout.dart';
import '../../../main.dart';

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

        return Scaffold(
          appBar: AppBar(
            title: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                double fontSize;

                if (screenWidth < 400) {
                  fontSize = 16; 
                } else if (screenWidth < 600) {
                  fontSize = 18;
                } else if (screenWidth < 900) {
                  fontSize = 20;
                } else {
                  fontSize = 24;
                }

                return Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 48,
                      width: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GameMaster Hub',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleTheme());
                },
                icon: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return Icon(
                      state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  context.go('/auth');
                },
                icon: const Icon(Icons.account_circle),
              ),
            ],
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

    return Center( // <-- Ajouté pour centrer horizontalement
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // <-- assure le centrage horizontal
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
        if (state is GamesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GamesError) {
          return Center(child: Text('Erreur: ${state.message}'));
        } else if (state is GamesLoaded) {
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
                  icon: Icons.videogame_asset, // ou mapper game.icon en IconData
                  priority: 1,
                  screenType: screenType,
                  cardWidth: cardWidth,
                  stats: {}, // stats à ajouter plus tard
                  onTap: () {
                    context.go(game.route ?? '/saves/$globalSaveId');
                  },
                ),
              );
            }).toList(),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

}