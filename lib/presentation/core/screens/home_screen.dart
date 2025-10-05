import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/theme/theme_bloc.dart';
import '../widgets/game_card.dart';
import '../utils/responsive_layout.dart';

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
            title: isMobile
                ? const Icon(Icons.sports_esports)
                : Row(
                    children: [
                      Icon(
                        Icons.sports_esports,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('GameMaster Hub'),
                    ],
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

    return Column(
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
    );
  }

  Widget _buildGamesGrid(BuildContext context, double width) {
    return BlocBuilder<JoueursSmBloc, JoueursSmState>(
      builder: (context, state) {
        int totalPlayersSM = 0;
        double averageRatingSM = 0;

        int totalPlayersFM = 0;
        double averageRatingFM = 0;

        if (state is JoueursSmLoaded) {
          final filteredPlayers = state.filteredJoueurs;
          totalPlayersSM = filteredPlayers.length;
          averageRatingSM = totalPlayersSM > 0
              ? filteredPlayers
                      .map((p) => p.joueur.niveauActuel)
                      .reduce((a, b) => a + b) /
                  totalPlayersSM
              : 0;

          totalPlayersFM = 45;
          averageRatingFM = 92;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenType = ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
            final cardConstraints = ResponsiveLayout.getGameCardConstraints(screenType);
            final spacing = screenType == ScreenType.mobile ? 16.0 : 24.0;

            // Calcul du nombre de colonnes optimal (max 3 pour les game cards)
            final crossAxisCount = ResponsiveLayout.calculateOptimalColumns(
              availableWidth: constraints.maxWidth,
              constraints: cardConstraints,
              spacing: spacing,
              maxColumns: 3,
            );

            // Calcul de la largeur effective pour chaque carte
            final totalSpacing = spacing * (crossAxisCount - 1);
            final availableForCards = constraints.maxWidth - totalSpacing;
            final cardWidth = cardConstraints.clampWidth(availableForCards / crossAxisCount);

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: GameCard(
                    title: 'Soccer Manager',
                    description: 'Gestion et analyse minimaliste',
                    icon: Icons.sports_soccer,
                    priority: 1,
                    screenType: screenType,
                    cardWidth: cardWidth,
                    stats: {
                      'Joueurs': '$totalPlayersSM',
                      'Note équipe': averageRatingSM.toStringAsFixed(0),
                    },
                    onTap: () => context.go('/sm'),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: GameCard(
                    title: 'Football Manager',
                    description: 'Gestion avancée et analyse détaillée',
                    icon: Icons.stadium,
                    priority: 2,
                    screenType: screenType,
                    cardWidth: cardWidth,
                    stats: {
                      'Joueurs': '$totalPlayersFM',
                      'Note équipe': averageRatingFM.toStringAsFixed(0),
                    },
                    onTap: () => context.go('/fm'),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: GameCard(
                    title: 'Star Wars GoH',
                    description: 'Optimiseur d\'équipe et simulateur',
                    icon: Icons.rocket_launch,
                    priority: 3,
                    screenType: screenType,
                    cardWidth: cardWidth,
                    stats: const {'Personnages': '156', 'Puissance': '4.2M'},
                    onTap: () => context.go('/swgoh'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}