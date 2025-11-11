import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/sm/entities/stats_joueur_sm.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

// ... (le reste de la classe AnalyseResult) ...
class AnalyseResult {
  final List<String> forces;
  final List<String> faiblesses;
  final List<String> manques;

  AnalyseResult({
    required this.forces,
    required this.faiblesses,
    required this.manques,
  });
}


class SMAnalyseLogic {
  static Future<AnalyseResult> analyser({
    required int saveId,
    required JoueursSmBloc bloc,
    required StatsJoueurSmRepositoryImpl joueurRepo,
    required StatsGardienSmRepositoryImpl gardienRepo,
  }) async {
    final joueursState = bloc.state;
    if (joueursState is! JoueursSmLoaded) {
      return AnalyseResult(forces: [], faiblesses: [], manques: []);
    }

    final joueurs = joueursState.joueurs;
    final forces = <String>[];
    final faiblesses = <String>[];
    final manques = <String>[];

    int nbDef = 0, nbMil = 0, nbAtt = 0, nbGk = 0;
    double defRating = 0, midRating = 0, attRating = 0;
    int nbJeunes = 0, nbVieux = 0;
    double ageMoyen = 0;
    final postesCount = <String, int>{};

    for (final j in joueurs) {
      final joueur = j.joueur;
      if (joueur.postes.isEmpty) continue;
      final poste = joueur.postes.first.name.toUpperCase();
      final age = joueur.age;
      ageMoyen += age;

      // Comptage postes
      postesCount[poste] = (postesCount[poste] ?? 0) + 1;

      if (age < 23) nbJeunes++;
      if (age > 30) nbVieux++;

      // === Gardien ===
      if (poste == 'GK') {
        nbGk++;
        final gk = await gardienRepo.getStatsByJoueurId(joueur.id, saveId);
        if (gk != null) {
          final note = (gk.arrets + gk.positionnement + gk.captation + gk.distribution + gk.autoriteSurface) / 5.0;
          if (note >= 75) forces.add("Gardien très fiable (${joueur.nom}, ${age} ans)");
          else if (note < 55) faiblesses.add("Gardien peu rassurant (${joueur.nom})");
        }
        continue;
      }

      final stats = await joueurRepo.getStatsByJoueurId(joueur.id, saveId);
      
      // LA CORRECTION CLÉ EST ICI (ligne décommentée)
      // Si le joueur n'a pas de stats, on l'ignore et on passe au suivant.
      if (stats == null) continue;

      // Le code ci-dessous est maintenant sûr
      final defense = (stats.marquage + stats.tacles + stats.positionnement) / 3.0;
      final attaque = (stats.finition + stats.frappesLointaines + stats.creativite) / 3.0;
      final milieu = (stats.passes + stats.controle + stats.dribble) / 3.0;
      final physique = (stats.vitesse + stats.endurance + stats.force) / 3.0;
      final moyenne = (defense + attaque + milieu + physique) / 4.0;
      
      // ... (le reste de la fonction est identique) ...
      
      // Par ligne
      if (poste.contains('DC') || poste.contains('DD') || poste.contains('DG')) {
        nbDef++;
        defRating += moyenne;
      } else if (poste.contains('MC') || poste.contains('MDC') || poste.contains('MOC')) {
        nbMil++;
        midRating += moyenne;
      } else if (poste.contains('BU') || poste.contains('AG') || poste.contains('AD') ||
                 poste.contains('MOG') || poste.contains('MOD') || poste.contains('AT')) {
        nbAtt++;
        attRating += moyenne;
      }

      // Forces / faiblesses individuelles
      if (moyenne >= 80) forces.add("${joueur.nom} (${age} ans) est un pilier à son poste ($poste)");
      else if (moyenne < 60) faiblesses.add("${joueur.nom} (${age} ans) montre des limites techniques ($poste)");

      if (physique >= 80 && age < 25) forces.add("${joueur.nom} affiche une excellente condition physique");
      if (creativiteElevee(stats)) forces.add("${joueur.nom} apporte de la créativité au jeu");
      if (attaque < 55 && poste.contains('BU')) faiblesses.add("${joueur.nom} manque d’efficacité devant le but");
      if (defense < 55 && poste.contains('DC')) faiblesses.add("${joueur.nom} fragile dans les duels défensifs");
    }

    // Moyennes par ligne
    final total = joueurs.isNotEmpty ? joueurs.length : 1;
    ageMoyen = ageMoyen / total;
    defRating = nbDef > 0 ? defRating / nbDef : 0;
    midRating = nbMil > 0 ? midRating / nbMil : 0;
    attRating = nbAtt > 0 ? attRating / nbAtt : 0;

    // === Analyses globales ===
    if (defRating >= 75) forces.add("Défense bien structurée");
    else if (defRating < 55) faiblesses.add("Défense vulnérable aux contre-attaques");

    if (midRating >= 75) forces.add("Milieu créatif et équilibré");
    else if (midRating < 55) faiblesses.add("Milieu sans impact sur la récupération");

    if (attRating >= 75) forces.add("Attaque efficace et collective");
    else if (attRating < 55) faiblesses.add("Manque de réalisme offensif");

    // === Jeunesse / expérience ===
    if (nbJeunes / total > 0.5) forces.add("Effectif jeune et prometteur");
    if (nbVieux / total > 0.4) forces.add("Effectif expérimenté, bonne stabilité");
    if (nbVieux / total > 0.6) faiblesses.add("Effectif vieillissant, à renouveler");
    if (ageMoyen < 24) faiblesses.add("Manque d’expérience dans les grands matchs");

    // === Manques quantitatifs ===
    if (nbGk == 0) manques.add("Aucun gardien disponible");
    if (nbDef < 3) manques.add("Pas assez de défenseurs centraux");
    if (nbMil < 3) manques.add("Milieu de terrain insuffisant");
    if (nbAtt < 3) manques.add("Manque d’attaquants");

    // === Cohérence du groupe ===
    final doublons = postesCount.entries.where((e) => e.value > 3).map((e) => e.key).toList();
    final absents = postesCount.entries.where((e) => e.value == 0).map((e) => e.key).toList();
    if (doublons.isNotEmpty) faiblesses.add("Surplus de joueurs à certains postes : ${doublons.join(', ')}");
    if (absents.isNotEmpty) manques.add("Aucun joueur à ces postes : ${absents.join(', ')}");

    // === Spécificités statistiques ===
    if (attRating > midRating + 10 && attRating > defRating + 10) forces.add("Équipe très portée vers l’attaque");
    if (defRating > attRating + 10) forces.add("Équipe solide mais peu offensive");
    if ((defRating - attRating).abs() < 5) forces.add("Équipe équilibrée entre défense et attaque");

    return AnalyseResult(forces: forces, faiblesses: faiblesses, manques: manques);
  }

  static bool creativiteElevee(StatsJoueurSm stats) {
    return stats.creativite > 75 && stats.passes > 75 && stats.dribble > 70;
  }
}