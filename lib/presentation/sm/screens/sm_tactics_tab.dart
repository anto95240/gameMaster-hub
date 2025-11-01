// lib/presentation/sm/screens/sm_tactics_tab.dart
import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
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
  int numberOfPlayers = 23;
  int teamRating = 87;

  void _onFormationChanged(String formation) {
    setState(() {
      selectedFormation = formation;
    });
  }

  void _onOptimize() {
    // Logique d'optimisation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Optimisation en cours...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 1200;
          final isMediumScreen = constraints.maxWidth > 800;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24 : (isMediumScreen ? 16 : 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LIGNE 1 : Titre + Stats
                  TacticsHeader(width: constraints.maxWidth),
                  SizedBox(height: isLargeScreen ? 24 : 16),

                  // LIGNE 2 : Cards + Bouton
                  TacticsCardsRow(
                    selectedFormation: selectedFormation,
                    onFormationChanged: _onFormationChanged,
                    onOptimize: _onOptimize,
                    isLargeScreen: isLargeScreen,
                    isMediumScreen: isMediumScreen,
                  ),
                  SizedBox(height: isLargeScreen ? 24 : 16),

                  // LIGNE 3 : Terrain
                  Center(
                    child: FootballField(
                      formation: selectedFormation,
                      isLargeScreen: isLargeScreen,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}