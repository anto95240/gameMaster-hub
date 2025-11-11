import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/data/data_export.dart'; // Requis pour les Repos
import 'package:gamemaster_hub/presentation/presentation_export.dart';

// ✅ CORRECTION 1: Le nom du fichier est 'sm_analyse_layout.dart'
// mais la classe à l'intérieur s'appelle 'AnalyseLayout'.
import 'package:gamemaster_hub/presentation/sm/widgets/sm_analyse_tab/sm_analyse_layout.dart';


class SMAnalyseTab extends StatefulWidget {
  final int saveId;

  const SMAnalyseTab({super.key, required this.saveId, required int currentTabIndex});

  @override
  State<SMAnalyseTab> createState() => _SMAnalyseTabState();
}

class _SMAnalyseTabState extends State<SMAnalyseTab>
    with AutomaticKeepAliveClientMixin<SMAnalyseTab> {
  
  late Future<AnalyseResult> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = _runAnalysis();
  }

  // Fonction helper pour appeler la méthode statique
  Future<AnalyseResult> _runAnalysis() {
    // Lire les dépendances depuis le contexte
    final bloc = context.read<JoueursSmBloc>();
    final joueurRepo = context.read<StatsJoueurSmRepositoryImpl>();
    final gardienRepo = context.read<StatsGardienSmRepositoryImpl>();

    // Appel à la méthode statique de SMAnalyseLogic
    return SMAnalyseLogic.analyser(
      saveId: widget.saveId,
      bloc: bloc,
      joueurRepo: joueurRepo,
      gardienRepo: gardienRepo,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<AnalyseResult>(
      future: _analysisFuture,
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Erreur lors de l'analyse: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          // ✅ CORRECTION 2: Nom de classe et constructeur
          // Nous appelons 'AnalyseLayout' (pas 'SMAnalyseLayout')
          // et nous lui passons les 3 listes séparément.
          final result = snapshot.data!;
          return AnalyseLayout(
            forces: result.forces,
            faiblesses: result.faiblesses,
            manques: result.manques,
          );
        }

        return const Center(child: Text("Aucune donnée d'analyse."));
      },
    );
  }
}