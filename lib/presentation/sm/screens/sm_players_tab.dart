import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/sm_blocs_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_widgets_export.dart';

class SMPlayersTab extends StatelessWidget {
  final int saveId;
  final int currentTabIndex;

  const SMPlayersTab({
    Key? key,
    required this.saveId,
    required this.currentTabIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = ResponsiveLayout.getHorizontalPadding(width);

    // 🧩 On écoute le Bloc pour les joueurs
    final joueursState = context.watch<JoueursSmBloc>().state;

    // ✅✅✅ CORRECTION CRUCIALE POUR LE _CastError ✅✅✅
    // Si l'état n'est pas "Loaded", on affiche un loader.
    // Cela empêche le header et la grille de planter lorsque le BLoC
    // passe en état "Loading" ou "Initial" (par ex. après optimisation).
    if (joueursState is! JoueursSmLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Si on arrive ici, joueursState EST un JoueursSmLoaded.
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: SMPlayersHeader(
              state: joueursState, // C'est sûr maintenant
              width: width,
              currentTabIndex: currentTabIndex,
              // selectedFormation n'est pas nécessaire ici (onglet 0)
            ),
          ),
          
          // Le reste de votre UI pour cet onglet
          SMPlayersFilters(
            state: joueursState,
            width: width,
          ), // Widget de filtres
          const SizedBox(height: 20),
          SMPlayersGrid(
            state: joueursState,
            width: width,
            saveId: saveId,
          ), // Grille des joueurs
        ],
      ),
    );
  }
}