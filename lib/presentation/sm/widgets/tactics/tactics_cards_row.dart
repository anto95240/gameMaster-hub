import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';

class TacticsCardsRow extends StatelessWidget {
  final String selectedFormation;
  final Function(String) onFormationChanged;
  final VoidCallback onOptimize;
  final bool isLargeScreen;
  final bool isMediumScreen;

  const TacticsCardsRow({
    Key? key,
    required this.selectedFormation,
    required this.onFormationChanged,
    required this.onOptimize,
    required this.isLargeScreen,
    required this.isMediumScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    final spacing = switch (screenType) {
      ScreenType.mobile => 16.0,
      ScreenType.tablet => 20.0,
      ScreenType.laptop => 28.0,
      ScreenType.laptopL => 32.0,
    };

    if (!isMediumScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormationCard(
            selectedFormation: selectedFormation,
            onFormationChanged: onFormationChanged,
            screenType: screenType,
          ),
          SizedBox(height: spacing),
          _StyleCard(screenType: screenType),
          SizedBox(height: spacing),
          Align(
            alignment: Alignment.center,
            child: _OptimizeButton(
              onOptimize: onOptimize,
              screenType: screenType,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: isLargeScreen ? 320 : 260,
          child: _FormationCard(
            selectedFormation: selectedFormation,
            onFormationChanged: onFormationChanged,
            screenType: screenType,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _StyleCard(screenType: screenType),
        ),
        SizedBox(width: spacing),
        _OptimizeButton(onOptimize: onOptimize, screenType: screenType),
      ],
    );
  }
}

class _FormationCard extends StatelessWidget {
  final String selectedFormation;
  final Function(String) onFormationChanged;
  final ScreenType screenType;

  const _FormationCard({
    required this.selectedFormation,
    required this.onFormationChanged,
    required this.screenType,
  });

  @override
  Widget build(BuildContext context) {
    final formations = [
      '4-3-3',
      '4-4-2',
      '3-5-2',
      '4-2-3-1',
      '5-3-2',
      '3-4-3',
      '4-1-2-1-2'
    ];

    final cardHeight = switch (screenType) {
      ScreenType.mobile => 180.0,
      ScreenType.tablet => 200.0,
      ScreenType.laptop => 220.0,
      ScreenType.laptopL => 240.0,
    };

    return Container(
      height: cardHeight,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3142),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Liste des Formations',
            style: TextStyle(
              color: Colors.white,
              fontSize: switch (screenType) {
                ScreenType.mobile => 13,
                ScreenType.tablet => 14,
                ScreenType.laptop => 15,
                ScreenType.laptopL => 16,
              },
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: switch (screenType) {
                  ScreenType.mobile => 2,
                  ScreenType.tablet => 3,
                  _ => 2,
                },
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.8,
              ),
              itemCount: formations.length,
              itemBuilder: (context, index) {
                final formation = formations[index];
                final isSelected = formation == selectedFormation;
                return InkWell(
                  onTap: () => onFormationChanged(formation),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4ECDC4).withOpacity(0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4ECDC4)
                            : Colors.white24,
                      ),
                    ),
                    child: Text(
                      formation,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF4ECDC4)
                            : Colors.white70,
                        fontSize: switch (screenType) {
                          ScreenType.mobile => 12,
                          ScreenType.tablet => 13,
                          ScreenType.laptop => 14,
                          ScreenType.laptopL => 15,
                        },
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  final ScreenType screenType;

  const _StyleCard({required this.screenType});

  @override
  Widget build(BuildContext context) {
    final cardHeight = switch (screenType) {
      ScreenType.mobile => 180.0,
      ScreenType.tablet => 200.0,
      ScreenType.laptop => 220.0,
      ScreenType.laptopL => 240.0,
    };

    return Container(
      height: cardHeight,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3142),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Liste des Styles de jeu',
            style: TextStyle(
              color: Colors.white,
              fontSize: switch (screenType) {
                ScreenType.mobile => 13,
                ScreenType.tablet => 14,
                ScreenType.laptop => 15,
                ScreenType.laptopL => 16,
              },
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              'Aucun style sélectionné',
              style: TextStyle(
                color: Colors.white54,
                fontSize: switch (screenType) {
                  ScreenType.mobile => 12,
                  ScreenType.tablet => 13,
                  ScreenType.laptop => 14,
                  ScreenType.laptopL => 15,
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimizeButton extends StatelessWidget {
  final VoidCallback onOptimize;
  final ScreenType screenType;

  const _OptimizeButton({
    required this.onOptimize,
    required this.screenType,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (screenType) {
      ScreenType.mobile => 46.0,
      ScreenType.tablet => 50.0,
      ScreenType.laptop => 52.0,
      ScreenType.laptopL => 56.0,
    };

    final fontSize = switch (screenType) {
      ScreenType.mobile => 14.0,
      ScreenType.tablet => 15.0,
      ScreenType.laptop => 16.0,
      ScreenType.laptopL => 17.0,
    };

    return Container(
      height: height,
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
          onTap: onOptimize,
          borderRadius: BorderRadius.circular(8),
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
}
