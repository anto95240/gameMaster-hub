import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_widgets_export.dart';

class SMTacticsTab extends StatefulWidget {
  final int saveId;
  final Game game;

  const SMTacticsTab({
    Key? key,
    required this.saveId,
    required this.game,
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

    final spacing = switch (screenType) {
      ScreenType.mobile => 10.0,
      ScreenType.tablet => 14.0,
      ScreenType.laptop => 18.0,
      ScreenType.laptopL => 22.0,
    };

    if (isMobile || isTablet) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: spacing / 2, bottom: spacing),
              child: TacticsHeader(width: width),
            ),

            _buildOptimizeButton(screenType),
            SizedBox(height: spacing * 1.2),

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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: spacing,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TacticsHeader(width: width),
          ),
          SizedBox(height: spacing),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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

                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildOptimizeButton(screenType),
                      SizedBox(height: spacing),
                      // 🧩 La carte prend plus de hauteur
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

  Widget _buildOptimizeButton(ScreenType screenType) {
    final height = switch (screenType) {
      ScreenType.mobile => 46.0,
      ScreenType.tablet => 50.0,
      ScreenType.laptop => 52.0,
      ScreenType.laptopL => 56.0,
    };

    final width = switch (screenType) {
      ScreenType.mobile => 160.0,
      ScreenType.tablet => 180.0,
      ScreenType.laptop => 200.0,
      ScreenType.laptopL => 220.0,
    };

    final fontSize = switch (screenType) {
      ScreenType.mobile => 14.0,
      ScreenType.tablet => 15.0,
      ScreenType.laptop => 16.0,
      ScreenType.laptopL => 17.0,
    };

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
        children: const [
          Text(
            'Liste des styles de jeu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14),
          Expanded(
            child: Center(
              child: Text(
                'Aucun style sélectionné pour le moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
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
