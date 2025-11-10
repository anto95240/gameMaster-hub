import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/sm_blocs_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_widgets_export.dart';

// Supposons que vous ayez un widget pour l'analyse
// import 'package:gamemaster_hub/presentation/sm/widgets/sm_analyse_tab/sm_analyse_layout.dart';

class SMAnalyseTab extends StatelessWidget {
  final int saveId;
  final int currentTabIndex;

  const SMAnalyseTab({
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
              // selectedFormation n'est pas nécessaire ici (onglet 2)
            ),
          ),

          // Le reste de votre UI pour cet onglet
          // Remplacez ceci par vos vrais widgets d'analyse
          const Text("Contenu de l'analyse ici"),
          // Exemple: SmAnalyseLayout(state: joueursState),
        ],
      ),
    );
  }
}