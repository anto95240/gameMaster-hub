import 'dart:math'; // Ajout pour pow() (Moyenne géométrique)
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
    required RoleModeleSmRepositoryImpl roleRepo,
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

    double avgEndurance = 0;
    double avgVitesseDef = 0;
    int defCount = 0;
    int fieldPlayersCount = 0;

    // --- ANALYSE DE L'EFFECTIF GLOBAL ---
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

          if (note >= 75) {
            forces.add("Gardien très fiable (${joueur.nom}, $age ans)");
          } else if (note < 55) {
            faiblesses.add("Gardien peu rassurant (${joueur.nom})");
          }
        }
        continue;
      }

      final stats = await joueurRepo.getStatsByJoueurId(joueur.id, saveId);
      if (stats == null) continue;

      fieldPlayersCount++;

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

      if (moyenne >= 80) {
        forces.add(
            "${joueur.nom} ($age ans) est un pilier à son poste ($poste)");
      } else if (moyenne < 60) {
        faiblesses
            .add("${joueur.nom} ($age ans) montre des limites techniques ($poste)");
      }

      if (physique >= 80 && age < 25) {
        forces.add("${joueur.nom} affiche une excellente condition physique");
      }
      if (creativiteElevee(stats)) {
        forces.add("${joueur.nom} apporte de la créativité au jeu");
      }
      if (attaque < 55 && poste.contains('BU')) {
        faiblesses.add("${joueur.nom} manque d’efficacité devant le but");
      }
      if (defense < 55 && poste.contains('DC')) {
        faiblesses.add("${joueur.nom} fragile dans les duels défensifs");
      }
    }

    final total = joueurs.isNotEmpty ? joueurs.length : 1;
    ageMoyen = ageMoyen / total;
    defRating = nbDef > 0 ? defRating / nbDef : 0;
    midRating = nbMil > 0 ? midRating / nbMil : 0;
    attRating = nbAtt > 0 ? attRating / nbAtt : 0;

    if (fieldPlayersCount > 0) {
      avgEndurance /= fieldPlayersCount;
    }
    if (defCount > 0) {
      avgVitesseDef /= defCount;
    }

    if (defRating >= 75) {
      forces.add("Défense (effectif) bien structurée");
    } else if (defRating < 55) {
      faiblesses.add("Défense (effectif) vulnérable");
    }

    if (midRating >= 75) {
      forces.add("Milieu (effectif) créatif et équilibré");
    } else if (midRating < 55) {
      faiblesses.add("Milieu (effectif) sans impact");
    }

    if (attRating >= 75) {
      forces.add("Attaque (effectif) efficace et collective");
    } else if (attRating < 55) {
      faiblesses.add("Manque de réalisme offensif (effectif)");
    }

    if (nbJeunes / total > 0.5) forces.add("Effectif jeune et prometteur");
    if (nbVieux / total > 0.4) {
      forces.add("Effectif expérimenté, bonne stabilité");
    }
    if (nbVieux / total > 0.6) {
      faiblesses.add("Effectif vieillissant, à renouveler");
    }
    if (ageMoyen < 24) {
      faiblesses.add("Manque d’expérience dans les grands matchs");
    }

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
    if (doublons.isNotEmpty) {
      faiblesses
          .add("Surplus de joueurs à certains postes : ${doublons.join(', ')}");
    }
    if (absents.isNotEmpty) {
      manques.add("Aucun joueur à ces postes : ${absents.join(', ')}");
    }

    // --- ANALYSE TACTIQUE (MOYENNES) ---
    final stylesAtt = tacticsState.stylesAttack;
    final stylesDef = tacticsState.stylesDefense;
    final formation = tacticsState.selectedFormation;

    if (tacticsState.assignedPlayersByPoste.isEmpty) {
      manques.add("Aucune tactique n'a été optimisée ou chargée.");
    } else {
      forces.add("Analyse basée sur la formation : $formation");

      if (stylesDef.keys.any((k) => k.contains('Pressing: Partout'))) {
        if (avgEndurance < 70 && avgEndurance > 0) {
          faiblesses.add(
              "Le 'Pressing Partout' (moyenne effectif) risque d'épuiser l'équipe (Endurance moy: ${avgEndurance.toStringAsFixed(0)}).");
        } else if (avgEndurance >= 70) {
          forces.add(
              "L'endurance (moyenne effectif) (${avgEndurance.toStringAsFixed(0)}) est parfaite pour le 'Pressing Partout'.");
        }
      }
      if (stylesDef.keys.any((k) => k.contains('Ligne défensive: Haut'))) {
        if (avgVitesseDef < 65 && avgVitesseDef > 0) {
          faiblesses.add(
              "Ligne défensive haute risquée (Vitesse moyenne défenseurs: ${avgVitesseDef.toStringAsFixed(0)}).");
        }
      }

      // ### AMÉLIORATION DRASITQUE : ANALYSE INDIVIDUELLE (TITULAIRES) ###

      for (final entry in tacticsState.assignedPlayersByPoste.entries) {
        final String posteKey = entry.key;
        final JoueurSmWithStats? playerWithStats = entry.value;

        if (playerWithStats == null) continue;

        final joueur = playerWithStats.joueur;
        final stats = playerWithStats.stats;
        final RoleModeleSm? assignedRole =
            tacticsState.assignedRolesByPlayerId[joueur.id];

        if (stats == null) continue;

        // 1. Vérification Adéquation Style / Joueur (Point faible individuel)
        if (stylesDef.keys.any((k) => k.contains('Pressing: Partout'))) {
          final endurance = _getStat(stats, 'endurance');
          if (endurance > 0 && endurance < 55) {
            faiblesses.add(
                "Faiblesse Style: ${joueur.nom} ($endurance en Endurance) risque d'être un point faible pour le 'Pressing Partout'.");
          }
        }

        if (stylesDef.keys.any((k) => k.contains('Ligne défensive: Haut'))) {
          if (posteKey.startsWith('D')) { // Si le joueur est un défenseur
            final vitesse = _getStat(stats, 'vitesse');
            if (vitesse > 0 && vitesse < 60) {
              faiblesses.add(
                  "Faiblesse Style: ${joueur.nom} ($vitesse en Vitesse) pourrait être pris de vitesse avec une Ligne Haute.");
            }
          }
        }

        if (stylesAtt.keys.any((k) => k.contains('Style de passe: Court'))) {
          final passes = _getStat(stats, 'passes');
          if (passes > 0 && passes < 60) {
            faiblesses.add(
                "Faiblesse Style: ${joueur.nom} ($passes en Passes) pourrait avoir du mal avec un style de 'Passe Courte'.");
          }
        }

        if (stylesAtt.keys.any((k) => k.contains('Style de passe: Ballon longs'))) {
          final passesLongues = _getStat(stats, 'passes_longues');
          if (passesLongues > 0 && passesLongues < 60) {
            faiblesses.add(
                "Faiblesse Style: ${joueur.nom} ($passesLongues en Passes Longues) n'est pas optimal pour 'Ballon longs'.");
          }
        }

        // 2. Vérification Adéquation Rôle / Joueur (Logique d'Harmonie)
        if (assignedRole != null) {
          final keyStats = _getKeyStatsForRole(assignedRole.role);

          // ### AMÉLIORATION : Utilisation de la moyenne géométrique pour l'analyse ###
          final avgRoleScore = _calculateRoleScore(stats, keyStats);

          if (avgRoleScore > 0 && avgRoleScore < 60) {
            faiblesses.add(
                "Incohérence Rôle: ${joueur.nom} (score: ${avgRoleScore.toStringAsFixed(0)}) est faible pour le rôle '${assignedRole.role}'.");
          } else if (avgRoleScore >= 75) {
            forces.add(
                "Adéquation Rôle: ${joueur.nom} (score: ${avgRoleScore.toStringAsFixed(0)}) est excellent en tant que '${assignedRole.role}'.");
          }
        }
      }
      // Fin de la nouvelle section d'analyse individuelle

      if (tacticsState.assignedPlayersByPoste.length < 11) {
        manques.add(
            "La tactique n'est pas complète, 11 joueurs ne sont pas assignés.");
      }
    }

    return AnalyseResult(
        forces: forces.toSet().toList(), // Éviter les doublons
        faiblesses: faiblesses.toSet().toList(),
        manques: manques.toSet().toList());
  }

  static bool creativiteElevee(StatsJoueurSm stats) {
    return stats.creativite > 75 && stats.passes > 75 && stats.dribble > 70;
  }

  // ### AMÉLIORATION : Helper Moyenne Géométrique (copié de l'optimiseur) ###
  static double _calculateRoleScore(dynamic stats, List<String> keyStats) {
    // Note : on ne peut pas accéder à player.averageRating ici,
    // donc on retourne 50.0 comme fallback si pas de stats clés.
    if (keyStats.isEmpty) {
      return 50.0;
    }

    double score = 1.0;
    int statsCount = 0;

    for (final statName in keyStats) {
      double statVal = _getStat(stats, statName).toDouble();
      score *= (statVal <= 0 ? 1.0 : statVal);
      statsCount++;
    }

    if (statsCount == 0) return 50.0;

    return pow(score, 1.0 / statsCount).toDouble();
  }

  static int _getStat(dynamic stats, String statName) {
    if (stats == null) return 0;
    try {
      final Map<String, dynamic> json;
      if (stats is StatsJoueurSmModel) {
        json = stats.toMap();
      } else if (stats is StatsGardienSmModel) {
        json = stats.toMap();
      } else {
        return 0; // Type de stats inconnu
      }

      final statKey = _statNameMapping[statName] ?? statName;

      if (json.containsKey(statKey)) {
        return (json[statKey] as num? ?? 0).toInt();
      }
    } catch (_) {}
    return 0;
  }

  static const Map<String, String> _statNameMapping = {
    'frappes_lointaines': 'frappesLointaines',
    'passes_longues': 'passesLongues',
    'coups_francs': 'coupsFrancs',
    'stabilite_aerienne': 'stabiliteAerienne',
    'distance_parcourue': 'distanceParcourue',
    'sang_froid': 'sangFroid',
    'autorite_surface': 'autoriteSurface'
  };

  // ### AMÉLIORATION : Mappage des rôles/stats mis à jour pour être cohérent ###
  static List<String> _getKeyStatsForRole(String roleName) {
    switch (roleName) {
      case 'Gardien':
        return ['arrets', 'positionnement', 'duels'];
      case 'Défenseur central':
        return ['marquage', 'tacles', 'force', 'positionnement', 'stabilite_aerienne'];
      case 'Défenseur relanceur':
        return ['marquage', 'passes', 'controle', 'creativite', 'sang_froid'];
      case 'Latéral':
        return ['vitesse', 'endurance', 'centres', 'tacles', 'marquage'];
      case 'Latéral offensif':
        return ['vitesse', 'endurance', 'centres', 'dribble', 'creativite', 'deplacement'];
      case 'Milieu récupérateur':
        return ['tacles', 'endurance', 'agressivite', 'positionnement', 'force'];
      case 'Meneur de jeu':
        return ['passes', 'creativite', 'controle', 'deplacement', 'sang_froid'];
      case 'Milieu polyvalent': // Box-to-Box
        return ['passes', 'endurance', 'tacles', 'deplacement', 'frappes_lointaines', 'finition'];
      case 'Milieu offensif':
        return ['creativite', 'dribble', 'frappes_lointaines', 'passes', 'deplacement'];
      case 'Ailier':
        return ['vitesse', 'dribble', 'centres', 'creativite', 'deplacement'];
      case 'Attaquant intérieur':
        return ['vitesse', 'dribble', 'finition', 'frappes_lointaines', 'deplacement', 'sang_froid'];
      case 'Buteur': // Renard des surfaces
        return ['finition', 'deplacement', 'sang_froid', 'stabilite_aerienne', 'vitesse'];
      case 'Attaquant de soutien': // Faux 9
        return ['finition', 'deplacement', 'creativite', 'passes', 'controle', 'dribble'];
      default:
        return [];
    }
  }
}