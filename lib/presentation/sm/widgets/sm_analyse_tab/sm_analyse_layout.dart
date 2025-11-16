import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'sm_analyse_card.dart';

class AnalyseLayout extends StatelessWidget {
  final List<String> forces;
  final List<String> faiblesses;
  final List<String> manques;

  const AnalyseLayout({
    super.key,
    required this.forces,
    required this.faiblesses,
    required this.manques,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenType = ResponsiveLayout.getScreenType(context);
    final spacing = switch (screenType) {
      ScreenType.mobile => 10.0,
      ScreenType.tablet => 14.0,
      ScreenType.laptop => 18.0,
      ScreenType.laptopL => 22.0,
    };

    final double cardWidth = switch (screenType) {
      ScreenType.mobile => width * 0.9,
      ScreenType.tablet => width * 0.45,
      ScreenType.laptop => width * 0.3,
      ScreenType.laptopL => width * 0.28,
    };

    return SingleChildScrollView(
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing * 1.2,
          runSpacing: spacing * 1.5,
          children: [
            SizedBox(
              width: cardWidth,
              child: AnalyseCard(
                title: "Faiblesses",
                color: Colors.redAccent.withOpacity(0.15),
                borderColor: Colors.redAccent,
                items: faiblesses,
                icon: Icons.trending_down,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: AnalyseCard(
                title: "Forces",
                color: Colors.greenAccent.withOpacity(0.15),
                borderColor: Colors.greenAccent,
                items: forces,
                icon: Icons.trending_up,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: AnalyseCard(
                title: "Manques",
                color: Colors.amberAccent.withOpacity(0.15),
                borderColor: Colors.amberAccent,
                items: manques,
                icon: Icons.warning_amber_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
