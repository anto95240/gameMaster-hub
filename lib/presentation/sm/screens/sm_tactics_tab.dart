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

  void _onOptimize() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Optimisation en cours...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 1200;
        final isMediumScreen = constraints.maxWidth > 800;

        // 🔹 Réduction légère des hauteurs globales
        final fieldHeight = isLargeScreen ? 480.0 : 400.0;
        final styleCardHeight = isLargeScreen ? 420.0 : 360.0;

        return Padding(
          padding: EdgeInsets.all(isLargeScreen ? 20 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟦 HEADER
              TacticsHeader(width: constraints.maxWidth),
              SizedBox(height: isLargeScreen ? 20 : 16),

              // 🟩 CONTENU PRINCIPAL (TERRAIN À GAUCHE + PANNEAU DROIT)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🟩 TERRAIN (1/3 de la largeur, vertical)
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: AspectRatio(
                          aspectRatio: 0.65, // ✅ Terrain vertical (portrait)
                          child: SizedBox(
                            height: fieldHeight,
                            child: FootballField(
                              formation: selectedFormation,
                              isLargeScreen: isLargeScreen,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ESPACE ENTRE LES DEUX BLOCS
                    const SizedBox(width: 20),

                    // 🟦 PANNEAU DROIT (2/3)
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          // 🔹 Bouton Optimiser
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 50,
                              width: isLargeScreen ? 180 : 160,
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
                                  child: const Center(
                                    child: Text(
                                      'Optimiser',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🔹 Carte Liste Styles de jeu
                          Container(
                            width: double.infinity,
                            height: styleCardHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2d3142),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Liste des styles de jeu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Aucun style sélectionné pour le moment.',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
