import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_widgets_export.dart';
import '../blocs/sm_blocs_export.dart';

class SMTacticsTab extends StatefulWidget {
  final int saveId;
  final Game game;
  final int currentTabIndex;

  const SMTacticsTab({
    Key? key,
    required this.saveId,
    required this.game,
    required this.currentTabIndex,
  }) : super(key: key);

  @override
  State<SMTacticsTab> createState() => _SMTacticsTabState();
}

class _SMTacticsTabState extends State<SMTacticsTab> {
  String selectedFormation = '4-3-3';

  void _onOptimize() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Optimisation en cours...')),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    // 🧩 On écoute le Bloc pour les joueurs
    final joueursState = context.watch<JoueursSmBloc>().state;
    final joueursLoaded = joueursState is JoueursSmLoaded
        ? joueursState
        : JoueursSmLoaded(joueurs: []);

    // ✅ Mobile & Tablette
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
              ),
            ),
            _buildOptimizeButton(screenType),
            SizedBox(height: spacing * 1.2),

            // ✅ Terrain
            SizedBox(
              height: isTablet ? 440 : 360,
              child: FootballField(
                formation: selectedFormation,
                isLargeScreen: false,
              ),
            ),

            SizedBox(height: spacing * 1.2),
            _buildStyleCard(isTablet ? 260 : 220),
          ],
        ),
      );
    }

    // ✅ Desktop / Laptop
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
            ),
          ),
          SizedBox(height: spacing),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ Terrain
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 0.65,
                      child: FootballField(
                        formation: selectedFormation,
                        isLargeScreen: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing * 1.4),

                // ✅ Panneau latéral (bouton + styles)
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildOptimizeButton(screenType),
                      SizedBox(height: spacing),
                      Expanded(child: _buildStyleCard(null)),
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
  Widget _buildOptimizeButton(ScreenType screenType) {
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
          onTap: _onOptimize,
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

  /// Carte de styles tactiques
  Widget _buildStyleCard(double? height) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3142),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liste des styles de jeu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: Text(
                'Aucun style sélectionné pour le moment.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
