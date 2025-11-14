import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_analyse_tab/sm_analyse_layout.dart';

class SMAnalyseTab extends StatelessWidget {
  final int saveId;
  final int currentTabIndex;

  const SMAnalyseTab(
      {super.key, required this.saveId, required this.currentTabIndex});

  @override
  Widget build(BuildContext context) {
    final joueursState = context.watch<JoueursSmBloc>().state;
    final tacticsState = context.watch<TacticsSmBloc>().state;

    if (joueursState is! JoueursSmLoaded ||
        tacticsState.status != TacticsStatus.loaded) {
      if (joueursState is JoueursSmLoading ||
          tacticsState.status == TacticsStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (joueursState is JoueursSmError) {
        return Center(
            child: Text("Erreur joueurs: ${joueursState.message}",
                style: const TextStyle(color: Colors.red)));
      }
      if (tacticsState.status == TacticsStatus.error) {
        return Center(
            child: Text("Erreur tactique: ${tacticsState.errorMessage}",
                style: const TextStyle(color: Colors.red)));
      }
      if (tacticsState.status != TacticsStatus.loaded) {
         return const Center(child: Text("Veuillez d'abord optimiser une tactique."));
      }
      return const Center(child: Text("Chargement des données..."));
    }

    try {
      final result = SMAnalyseLogic.analyser(
        joueursState: joueursState,
        tacticsState: tacticsState,
      );

      return AnalyseLayout(
        forces: result.forces,
        faiblesses: result.faiblesses,
        manques: result.manques,
      );
    } catch (e) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Erreur lors de l'analyse: $e",
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}