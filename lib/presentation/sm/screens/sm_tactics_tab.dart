// [lib/presentation/sm/screens/sm_tactics_tab.dart]
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_widgets_export.dart';
import '../blocs/sm_blocs_export.dart';

// ... (la map _allStyles reste la même)
const Map<String, List<String>> _allStyles = {
  'Général': [
    'Largeur: Étroit', 'Largeur: Normal', 'Largeur: Jeu large',
    'Mentalité: Très défensive', 'Mentalité: Défensive', 'Mentalité: Normal', 'Mentalité: Offensive', 'Mentalité: Très offensive',
    'Tempo: Lent', 'Tempo: Normal', 'Tempo: Rapide',
    'Fluidité de la formation: Discipliné', 'Fluidité de la formation: Normal', 'Fluidité de la formation: Aventureux',
    'Rythme de travail: Lent', 'Rythme de travail: Normal', 'Rythme de travail: Rapide',
    'Créativité: Prudent', 'Créativité: Équilibré', 'Créativité: Audacieux',
  ],
  'Attaque': [
    'Style de passe: Court', 'Style de passe: Polyvalent', 'Style de passe: Direct', 'Style de passe: Ballon longs',
    'Style d\'attaque: Polyvalent', 'Style d\'attaque: Sur les deux ailes', 'Style d\'attaque: Sur l\'aide gauche', 'Style d\'attaque: Sur l\'aile droite', 'Style d\'attaque: Par l\'axe',
    'Attaquants: Polyvalents', 'Attaquants: Jouer le ballon dans la surface', 'Attaquants: Tirer à vue',
    'Jeu large: Polyvalent', 'Jeu large: Centres de la ligne de touche', 'Jeu large: Anticipez avec des passes transversales', 'Jeu large: Jouer le ballon dans la surface',
    'Jeu en contruction: Lent', 'Jeu en contruction: Normal', 'Jeu en contruction: Rapide',
    'Contre-attaque: Oui', 'Contre-attaque: Non',
  ],
  'Défense': [
    'Pressing: Propre surface de réparation', 'Pressing: Propre moitié de terrain', 'Pressing: Partout',
    'Style tacle: Normal', 'Style tacle: Rugeux', 'Style tacle: Agressif',
    'Ligne défensive: Bas', 'Ligne défensive: Normal', 'Ligne défensive: Haut',
    'Gardien libéro: Oui', 'Gardien libéro: Non',
    'Perte de temps: Faible', 'Perte de temps: Normal', 'Perte de temps: Haut',
  ],
};


class SMTacticsTab extends StatefulWidget {
  final int saveId;
  final Game game;
  final int currentTabIndex;

  const SMTacticsTab({
    super.key,
    required this.saveId,
    required this.game,
    required this.currentTabIndex,
  });

  @override
  State<SMTacticsTab> createState() => _SMTacticsTabState();
}

class _SMTacticsTabState extends State<SMTacticsTab>
    with AutomaticKeepAliveClientMixin<SMTacticsTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<TacticsSmBloc>().add(LoadTactics(widget.saveId));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenType = ResponsiveLayout.getScreenType(context);
    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;

    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = ResponsiveLayout.getHorizontalPadding(width);

    final spacing = (screenType == ScreenType.mobile)
        ? 10.0
        : (screenType == ScreenType.tablet)
            ? 14.0
            : (screenType == ScreenType.laptop)
                ? 18.0
                : 22.0;

    final joueursState = context.watch<JoueursSmBloc>().state;
    final tacticsState = context.watch<TacticsSmBloc>().state;

    final joueursLoaded = joueursState is JoueursSmLoaded
        ? joueursState
        : const JoueursSmLoaded(joueurs: []); // Fallback

    if (tacticsState.status == TacticsStatus.loading ||
        tacticsState.status == TacticsStatus.initial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Chargement..."),
          ],
        ),
      );
    }

    if (tacticsState.status == TacticsStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              "Erreur lors du chargement",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                tacticsState.errorMessage ?? "Une erreur inconnue est survenue.",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _buildOptimizeButton(
              context,
              screenType,
              () => context
                  .read<TacticsSmBloc>()
                  .add(OptimizeTactics(widget.saveId)),
            ),
          ],
        ),
      );
    }

    // Mobile & Tablette
    if (isMobile || isTablet) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: spacing / 2, bottom: spacing),
              child: SMPlayersHeader(
                state: joueursLoaded,
                width: width,
                currentTabIndex: widget.currentTabIndex,
                selectedFormation: tacticsState.selectedFormation,
              ),
            ),
            _buildOptimizeButton(
              context,
              screenType,
              () => context
                  .read<TacticsSmBloc>()
                  .add(OptimizeTactics(widget.saveId)),
            ),
            SizedBox(height: spacing * 1.2),
            FootballField(
              formation: tacticsState.selectedFormation,
              isLargeScreen: false,
              assignedPlayersByPoste: tacticsState.assignedPlayersByPoste,
              assignedRolesByPlayerId: tacticsState.assignedRolesByPlayerId,
              allPlayers: joueursState,
            ),
            SizedBox(height: spacing * 1.2),
            _buildStyleCard(
              optimizedStyles: {
                'Général': tacticsState.stylesGeneral,
                'Attaque': tacticsState.stylesAttack,
                'Défense': tacticsState.stylesDefense,
              },
            ),
          ],
        ),
      );
    }

    // Desktop / Laptop
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: spacing,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SMPlayersHeader(
              state: joueursLoaded,
              width: width,
              currentTabIndex: widget.currentTabIndex,
              selectedFormation: tacticsState.selectedFormation,
            ),
          ),
          SizedBox(height: spacing),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Flex ratio ajusté (terrain plus grand)
                Expanded(
                  flex: 6,
                  child: Center(
                    child: FootballField(
                      formation: tacticsState.selectedFormation,
                      isLargeScreen: true,
                      assignedPlayersByPoste:
                          tacticsState.assignedPlayersByPoste,
                      assignedRolesByPlayerId:
                          tacticsState.assignedRolesByPlayerId,
                      allPlayers: joueursState,
                    ),
                  ),
                ),
                SizedBox(width: spacing * 1.4),
                // ✅ Flex ratio ajusté (carte style plus étroite)
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildOptimizeButton(
                        context,
                        screenType,
                        () => context
                            .read<TacticsSmBloc>()
                            .add(OptimizeTactics(widget.saveId)),
                      ),
                      SizedBox(height: spacing),
                      // L'Expanded ici permet à la carte de ne pas déborder
                      // si le contenu est grand, mais _buildStyleCard
                      // utilisera MainAxisSize.min
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildStyleCard(
                            optimizedStyles: {
                              'Général': tacticsState.stylesGeneral,
                              'Attaque': tacticsState.stylesAttack,
                              'Défense': tacticsState.stylesDefense,
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton "Optimiser ma tactique"
  Widget _buildOptimizeButton(
      BuildContext context, ScreenType screenType, VoidCallback onPressed) {
    final height = (screenType == ScreenType.mobile)
        ? 46.0
        : (screenType == ScreenType.tablet)
            ? 50.0
            : (screenType == ScreenType.laptop)
                ? 52.0
                : 56.0;

    final width = (screenType == ScreenType.mobile)
        ? 160.0
        : (screenType == ScreenType.tablet)
            ? 180.0
            : (screenType == ScreenType.laptop)
                ? 200.0
                : 220.0;

    final fontSize = (screenType == ScreenType.mobile)
        ? 14.0
        : (screenType == ScreenType.tablet)
            ? 15.0
            : (screenType == ScreenType.laptop)
                ? 16.0
                : 17.0;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4dd0e1), Color(0xFFffeb3b)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Center(
            child: Text(
              'Optimiser',
              style: TextStyle(
                color: Colors.black87,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section de style
  Widget _buildStyleSection(
    String title,
    List<String> allStyles,
    Map<String, double> optimizedStyles,
  ) {
    final optimizedKeys = optimizedStyles.keys.toSet();

    Map<String, List<String>> groupedStyles = {};
    for (String styleName in allStyles) {
      String type = styleName.split(': ')[0];
      if (!groupedStyles.containsKey(type)) {
        groupedStyles[type] = [];
      }
      groupedStyles[type]!.add(styleName);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4dd0e1),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...groupedStyles.entries.map((entry) {
            final styleType = entry.key;
            final styleOptions = entry.value;

            final selectedOption = styleOptions.firstWhere(
              (option) => optimizedKeys.contains(option),
              orElse: () => "$styleType: N/A",
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Gère les retours à la ligne
                children: [
                  Text(
                    "$styleType: ",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      selectedOption.split(': ').last,
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Carte de style
  Widget _buildStyleCard({
    required Map<String, Map<String, double>> optimizedStyles,
  }) {
    final bool hasStyles = (optimizedStyles['Général']?.isNotEmpty ?? false) ||
        (optimizedStyles['Attaque']?.isNotEmpty ?? false) ||
        (optimizedStyles['Défense']?.isNotEmpty ?? false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3142),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Raccourcit la carte
        children: [
          const Text(
            'Styles de jeu optimisés',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (!hasStyles)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'Cliquez sur "Optimiser" pour générer les styles de jeu adaptés.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          if (hasStyles)
            // ✅ Layout changé pour s'adapter à une largeur réduite
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStyleSection(
                  'Général',
                  _allStyles['Général']!,
                  optimizedStyles['Général']!,
                ),
                const SizedBox(height: 12),
                _buildStyleSection(
                  'Attaque',
                  _allStyles['Attaque']!,
                  optimizedStyles['Attaque']!,
                ),
                const SizedBox(height: 12),
                _buildStyleSection(
                  'Défense',
                  _allStyles['Défense']!,
                  optimizedStyles['Défense']!,
                ),
              ],
            ),
        ],
      ),
    );
  }
}