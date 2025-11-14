import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

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
    required JoueursSmLoaded joueursState,
    required TacticsSmState tacticsState,
    required StatsJoueurSmRepositoryImpl joueurRepo,
    required StatsGardienSmRepositoryImpl gardienRepo,
  }) async {
    final joueurs = joueursState.joueurs;
    final forces = <String>[];
    final faiblesses = <String>[];
    final manques = <String>[];

    int nbDef = 0, nbMil = 0, nbAtt = 0, nbGk = 0;
    double defRating = 0, midRating = 0, attRating = 0;
    int nbJeunes = 0, nbVieux = 0;
    double ageMoyen = 0;
    final postesCount = <String, int>{};

    double avgPassesLongues = 0;
    double avgEndurance = 0;
    double avgVitesseDef = 0;
    int defCount = 0;
    int fieldPlayersCount = 0;

    for (final j in joueurs) {
      final joueur = j.joueur;
      if (joueur.postes.isEmpty) continue;
      final poste = joueur.postes.first.name.toUpperCase();
      final age = joueur.age;
      ageMoyen += age;

      postesCount[poste] = (postesCount[poste] ?? 0) + 1;

      if (age < 23) nbJeunes++;
      if (age > 30) nbVieux++;

      if (poste == 'G') {
        nbGk++;
        final gk = await gardienRepo.getStatsByJoueurId(joueur.id, saveId);
        if (gk != null) {
          final note = (gk.arrets +
                  gk.positionnement +
                  gk.captation +
                  gk.distribution +
                  gk.autoriteSurface) /
              5.0;
          if (note >= 75)
            forces.add("Gardien très fiable (${joueur.nom}, ${age} ans)");
          else if (note < 55)
            faiblesses.add("Gardien peu rassurant (${joueur.nom})");
        }
        continue;
      }

      final stats = await joueurRepo.getStatsByJoueurId(joueur.id, saveId);
      if (stats == null) continue;
      
      fieldPlayersCount++; 
      
      avgPassesLongues += stats.passesLongues;
      avgEndurance += stats.endurance;
      
      if (poste.contains('DC') || poste.contains('DD') || poste.contains('DG')) {
        avgVitesseDef += stats.vitesse;
        defCount++;
      }

      final defense =
          (stats.marquage + stats.tacles + stats.positionnement) / 3.0;
      final attaque =
          (stats.finition + stats.frappesLointaines + stats.creativite) / 3.0;
      final milieu = (stats.passes + stats.controle + stats.dribble) / 3.0;
      final physique = (stats.vitesse + stats.endurance + stats.force) / 3.0;
      final moyenne = (defense + attaque + milieu + physique) / 4.0;

      if (poste.contains('DC') || poste.contains('DD') || poste.contains('DG')) {
        nbDef++;
        defRating += moyenne;
      } else if (poste.contains('MC') ||
          poste.contains('MDC') ||
          poste.contains('MOC')) {
        nbMil++;
        midRating += moyenne;
      } else if (poste.contains('BU') ||
          poste.contains('AG') ||
          poste.contains('AD') ||
          poste.contains('MOG') ||
          poste.contains('MOD') ||
          poste.contains('AT')) {
        nbAtt++;
        attRating += moyenne;
      }

      if (moyenne >= 80)
        forces.add(
            "${joueur.nom} (${age} ans) est un pilier à son poste ($poste)");
      else if (moyenne < 60)
        faiblesses
            .add("${joueur.nom} (${age} ans) montre des limites techniques ($poste)");

      if (physique >= 80 && age < 25)
        forces.add("${joueur.nom} affiche une excellente condition physique");
      if (creativiteElevee(stats))
        forces.add("${joueur.nom} apporte de la créativité au jeu");
      if (attaque < 55 && poste.contains('BU'))
        faiblesses.add("${joueur.nom} manque d’efficacité devant le but");
      if (defense < 55 && poste.contains('DC'))
        faiblesses
            .add("${joueur.nom} fragile dans les duels défensifs");
    }

    final total = joueurs.isNotEmpty ? joueurs.length : 1;
    ageMoyen = ageMoyen / total;
    defRating = nbDef > 0 ? defRating / nbDef : 0;
    midRating = nbMil > 0 ? midRating / nbMil : 0;
    attRating = nbAtt > 0 ? attRating / nbAtt : 0;

    if (fieldPlayersCount > 0) {
      avgPassesLongues /= fieldPlayersCount;
      avgEndurance /= fieldPlayersCount;
    }
    if (defCount > 0) {
      avgVitesseDef /= defCount;
    }

    if (defRating >= 75)
      forces.add("Défense bien structurée");
    else if (defRating < 55)
      faiblesses.add("Défense vulnérable aux contre-attaques");

    if (midRating >= 75)
      forces.add("Milieu créatif et équilibré");
    else if (midRating < 55)
      faiblesses.add("Milieu sans impact sur la récupération");

    if (attRating >= 75)
      forces.add("Attaque efficace et collective");
    else if (attRating < 55)
      faiblesses.add("Manque de réalisme offensif");

    if (nbJeunes / total > 0.5) forces.add("Effectif jeune et prometteur");
    if (nbVieux / total > 0.4)
      forces.add("Effectif expérimenté, bonne stabilité");
    if (nbVieux / total > 0.6)
      faiblesses.add("Effectif vieillissant, à renouveler");
    if (ageMoyen < 24)
      faiblesses.add("Manque d’expérience dans les grands matchs");

    if (nbGk == 0) manques.add("Aucun gardien disponible");
    if (nbDef < 3) manques.add("Pas assez de défenseurs centraux");
    if (nbMil < 3) manques.add("Milieu de terrain insuffisant");
    if (nbAtt < 3) manques.add("Manque d’attaquants");

    final doublons = postesCount.entries
        .where((e) => e.value > 3)
        .map((e) => e.key)
        .toList();
    final absents = postesCount.entries
        .where((e) => e.value == 0)
        .map((e) => e.key)
        .toList();
    if (doublons.isNotEmpty)
      faiblesses
          .add("Surplus de joueurs à certains postes : ${doublons.join(', ')}");
    if (absents.isNotEmpty)
      manques.add("Aucun joueur à ces postes : ${absents.join(', ')}");

    if (attRating > midRating + 10 && attRating > defRating + 10)
      forces.add("Équipe très portée vers l’attaque");
    if (defRating > attRating + 10)
      forces.add("Équipe solide mais peu offensive");
    if ((defRating - attRating).abs() < 5)
      forces.add("Équipe équilibrée entre défense et attaque");

    final stylesGen = tacticsState.stylesGeneral;
    final stylesAtt = tacticsState.stylesAttack;
    final stylesDef = tacticsState.stylesDefense;
    final formation = tacticsState.selectedFormation;

    if (tacticsState.assignedPlayersByPoste.isEmpty) {
      manques.add("Aucune tactique n'a été optimisée ou chargée.");
    } else {
      forces.add("Analyse basée sur la formation : $formation");
      
      if (formation == '3-5-2' || formation == '3-4-3') {
        if (defRating < 70 && defRating > 0) {
          faiblesses.add(
              "Une défense à 3 ($formation) est risquée avec une note défensive moyenne de ${defRating.toStringAsFixed(0)}.");
        } else if (defRating >= 70) {
          forces.add(
              "La défense à 3 ($formation) est solide (${defRating.toStringAsFixed(0)}) et libère les ailes.");
        }
      }
      if (formation == '4-4-2') {
        if (midRating < 70 && midRating > 0) {
          faiblesses.add(
              "Le 4-4-2 nécessite un milieu solide; la note actuelle (${midRating.toStringAsFixed(0)}) est un peu faible.");
        }
      }

      if (stylesGen.keys.any((k) => k.contains('Très offensive'))) {
        if (attRating < 75 && attRating > 0) {
          faiblesses.add(
              "Style 'Très offensif' choisi, mais l'attaque (${attRating.toStringAsFixed(0)}) n'est pas encore au niveau.");
        } else if (attRating >= 75) {
          forces.add(
              "Le style 'Très offensif' correspond bien à la note d'attaque élevée (${attRating.toStringAsFixed(0)}).");
        }
      }

      if (stylesGen.keys.any((k) => k.contains('Très défensive'))) {
        if (defRating < 75 && defRating > 0) {
          faiblesses.add(
              "Style 'Très défensif' choisi, mais la défense (${defRating.toStringAsFixed(0)}) doit être renforcée.");
        } else if (defRating >= 75) {
          forces.add(
              "Le style 'Très défensif' maximise la solidité de l'équipe (${defRating.toStringAsFixed(0)}).");
        }
      }

      if (stylesAtt.keys.any((k) => k.contains('Ballon longs'))) {
        if (avgPassesLongues < 65 && avgPassesLongues > 0) {
          faiblesses.add(
              "Style 'Balles longues' choisi, mais la moyenne de passes longues (${avgPassesLongues.toStringAsFixed(0)}) est faible.");
        }
      }

      if (stylesDef.keys.any((k) => k.contains('Pressing: Partout'))) {
        if (avgEndurance < 70 && avgEndurance > 0) {
          faiblesses.add(
              "Le 'Pressing Partout' risque d'épuiser l'équipe (Endurance moy: ${avgEndurance.toStringAsFixed(0)}).");
        } else if (avgEndurance >= 70) {
          forces.add(
              "L'endurance élevée (${avgEndurance.toStringAsFixed(0)}) est parfaite pour le 'Pressing Partout'.");
        }
      }

      if (stylesDef.keys.any((k) => k.contains('Ligne défensive: Haut'))) {
        if (avgVitesseDef < 65 && avgVitesseDef > 0) {
          faiblesses.add(
              "Ligne défensive haute risquée (Vitesse défenseurs: ${avgVitesseDef.toStringAsFixed(0)}).");
        }
      }
      
      if (tacticsState.assignedPlayersByPoste.length < 11) {
        manques.add("La tactique n'est pas complète, 11 joueurs ne sont pas assignés.");
      }
    }

    return AnalyseResult(
        forces: forces, faiblesses: faiblesses, manques: manques);
  }

  static bool creativiteElevee(StatsJoueurSm stats) {
    return stats.creativite > 75 && stats.passes > 75 && stats.dribble > 70;
  }
}