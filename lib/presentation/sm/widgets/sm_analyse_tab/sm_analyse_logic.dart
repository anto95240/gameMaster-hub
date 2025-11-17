// lib/presentation/sm/widgets/sm_analyse_tab/sm_analyse_logic.dart
import 'dart:math';
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
    
    int nbTalents = 0;
    int nbEclosion = 0;
    int nbPrime = 0;
    int nbVeterans = 0;
    
    double ageMoyen = 0;
    final postesCount = <String, int>{};

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

      if (age < 20) {
        nbTalents++;
      } else if (age >= 20 && age <= 23) {
        nbEclosion++;
      } else if (age >= 24 && age <= 29) {
        nbPrime++;
      } else if (age >= 30) {
        nbVeterans++;
      }

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

    if (nbGk == 0) manques.add("Aucun gardien disponible.");
    if (nbDef < 3) manques.add("Pas assez de défenseurs centraux.");
    if (nbMil < 3) manques.add("Milieu de terrain insuffisant.");
    if (nbAtt < 3) manques.add("Manque d’attaquants.");

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
    
    if (nbTalents > 5) {
      forces.add("Excellent vivier de jeunes talents (< 20 ans).");
    } else if (nbTalents < 2) {
      manques.add("Manque de jeunes talents (< 20 ans) pour préparer le futur.");
    }
    
    if (nbEclosion > 5) {
      forces.add("Bon noyau de joueurs en pleine éclosion (20-23 ans).");
    } else if (nbEclosion < 3) {
      manques.add("Peu de joueurs en phase d'éclosion (20-23 ans).");
    }

    if (nbPrime > 8) {
      forces.add("Majorité de l'effectif dans son prime (24-29 ans), prête pour la performance immédiate.");
    } else if (nbPrime < 5) {
      manques.add("Manque de joueurs au sommet de leur carrière (24-29 ans).");
    }
    
    if (nbVeterans > 5) {
      forces.add("Équipe très expérimentée (Vétérans >= 30 ans).");
    } else if (nbVeterans < 2) {
      manques.add("Manque d'expérience (Vétérans >= 30 ans) pour encadrer l'équipe.");
    }
    
    if ((nbVeterans / total) > 0.6) {
      faiblesses.add("Effectif vieillissant (moyenne d'âge : ${ageMoyen.toStringAsFixed(1)} ans), risque sur l'endurance et les blessures.");
    }
    if (ageMoyen < 23) {
      faiblesses.add("Effectif très jeune (moyenne d'âge : ${ageMoyen.toStringAsFixed(1)} ans), manque d'expérience global.");
    }

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

      for (final entry in tacticsState.assignedPlayersByPoste.entries) {
        final String posteKey = entry.key;
        final JoueurSmWithStats? playerWithStats = entry.value;

        if (playerWithStats == null) continue;

        final joueur = playerWithStats.joueur;
        final stats = playerWithStats.stats;
        final RoleModeleSm? assignedRole =
            tacticsState.assignedRolesByPlayerId[joueur.id];

        if (stats == null) continue;

        if (stylesDef.keys.any((k) => k.contains('Pressing: Partout'))) {
          final endurance = _getStat(stats, 'endurance');
          if (endurance > 0 && endurance < 55) {
            faiblesses.add(
                "Faiblesse Style: ${joueur.nom} ($endurance en Endurance) risque d'être un point faible pour le 'Pressing Partout'.");
          }
        }

        if (stylesDef.keys.any((k) => k.contains('Ligne défensive: Haut'))) {
          if (posteKey.startsWith('D')) {
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

        if (assignedRole != null) {
          final keyStats = _getKeyStatsForRole(assignedRole.role);
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

      if (tacticsState.assignedPlayersByPoste.length < 11) {
        manques.add(
            "La tactique n'est pas complète, 11 joueurs ne sont pas assignés.");
      }
    }

    return AnalyseResult(
        forces: forces.toSet().toList(),
        faiblesses: faiblesses.toSet().toList(),
        manques: manques.toSet().toList());
  }

  static bool creativiteElevee(StatsJoueurSm stats) {
    return stats.creativite > 75 && stats.passes > 75 && stats.dribble > 70;
  }

  static double _getGeoMean(dynamic stats, List<String> statNames) {
    if (statNames.isEmpty) {
      return 50.0;
    }
    double score = 1.0;
    int statsCount = 0;
    for (final statName in statNames) {
      double statVal = _getStat(stats, statName).toDouble();
      score *= (statVal <= 0 ? 1.0 : statVal);
      statsCount++;
    }
    if (statsCount == 0) return 50.0;
    return pow(score, 1.0 / statsCount).toDouble();
  }
  
  static double _calculateRoleScore(dynamic stats, Map<String, List<String>> keyStats) {
    final primaryStats = keyStats['primary'] ?? [];
    final secondaryStats = keyStats['secondary'] ?? [];
    final tertiaryStats = keyStats['tertiary'] ?? [];

    if (primaryStats.isEmpty && secondaryStats.isEmpty && tertiaryStats.isEmpty) {
      return 50.0;
    }

    final primaryScore = _getGeoMean(stats, primaryStats);
    final secondaryScore = _getGeoMean(stats, secondaryStats);
    final tertiaryScore = _getGeoMean(stats, tertiaryStats);

    double totalScore = 0;
    double totalWeight = 0;

    if (primaryStats.isNotEmpty) {
      totalScore += primaryScore * 0.60;
      totalWeight += 0.60;
    }
    if (secondaryStats.isNotEmpty) {
      totalScore += secondaryScore * 0.30;
      totalWeight += 0.30;
    }
    if (tertiaryStats.isNotEmpty) {
      totalScore += tertiaryScore * 0.10;
      totalWeight += 0.10;
    }

    if (totalWeight == 0) return 50.0;
    return totalScore / totalWeight;
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
        return 0;
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

  static Map<String, List<String>> _getKeyStatsForRole(String roleName) {
    switch (roleName) {
      case 'Gardien':
        return {'primary': ['arrets', 'positionnement'], 'secondary': ['duels', 'autorite_surface'], 'tertiary': ['sang_froid']};
      case 'Gardien libéro':
        return {'primary': ['arrets', 'vitesse', 'distribution'], 'secondary': ['controle', 'sang_froid'], 'tertiary': ['passes']};

      case 'stoppeur':
        return {'primary': ['marquage', 'tacles', 'force'], 'secondary': ['agressivite', 'stabilite_aerienne'], 'tertiary': ['positionnement']};
      case 'défenseur relanceur':
        return {'primary': ['passes', 'creativite', 'controle'], 'secondary': ['marquage', 'sang_froid'], 'tertiary': ['dribble', 'tacles']};
      case 'désenseur':
        return {'primary': ['marquage', 'tacles', 'positionnement'], 'secondary': ['force', 'endurance'], 'tertiary': ['passes']};

      case 'latéral offensif':
        return {'primary': ['vitesse', 'centres', 'dribble'], 'secondary': ['endurance', 'creativite'], 'tertiary': ['deplacement', 'passes']};
      case 'défenseur latéral':
        return {'primary': ['tacles', 'marquage', 'positionnement'], 'secondary': ['endurance', 'vitesse'], 'tertiary': ['centres', 'agressivite']};

      case 'meneur de jeu en retrait':
        return {'primary': ['passes', 'passes_longues', 'creativite'], 'secondary': ['controle', 'sang_froid'], 'tertiary': ['positionnement']};
      case 'milieu récupérateur':
        return {'primary': ['tacles', 'agressivite', 'positionnement'], 'secondary': ['endurance', 'force'], 'tertiary': ['marquage']};
      case 'milieu de terrain relayeur':
        return {'primary': ['endurance', 'deplacement', 'passes'], 'secondary': ['tacles', 'dribble'], 'tertiary': ['finition', 'frappes_lointaines']};
      case 'milieu de terrain':
        return {'primary': ['passes', 'tacles', 'endurance'], 'secondary': ['deplacement', 'positionnement'], 'tertiary': ['force']};
      case 'meneur de jeu':
        return {'primary': ['passes', 'creativite', 'sang_froid'], 'secondary': ['passes_longues', 'controle'], 'tertiary': ['deplacement']};
      case 'meneur de jeu avancé':
        return {'primary': ['creativite', 'passes', 'dribble'], 'secondary': ['controle', 'deplacement'], 'tertiary': ['finition', 'frappes_lointaines']};
      case 'milieu latéral':
        return {'primary': ['endurance', 'centres', 'vitesse'], 'secondary': ['passes', 'tacles', 'marquage'], 'tertiary': ['positionnement']};

      case 'Attaquant intérieur':
        return {'primary': ['vitesse', 'finition', 'deplacement'], 'secondary': ['dribble', 'sang_froid'], 'tertiary': ['passes', 'frappes_lointaines']};
      case 'Ailier':
        return {'primary': ['vitesse', 'dribble', 'centres'], 'secondary': ['endurance', 'controle'], 'tertiary': ['deplacement', 'creativite']};
      case 'Finisseur':
        return {'primary': ['finition', 'deplacement', 'sang_froid'], 'secondary': ['vitesse', 'stabilite_aerienne'], 'tertiary': ['force']};
      case 'Attaquant en retrait':
        return {'primary': ['deplacement', 'passes', 'creativite'], 'secondary': ['controle', 'dribble'], 'tertiary': ['finition', 'sang_froid']};
      case 'Attaquant de pointe':
        return {'primary': ['force', 'stabilite_aerienne', 'finition'], 'secondary': ['controle', 'passes'], 'tertiary': ['deplacement']};
      case 'Attaquant':
        return {'primary': ['finition', 'vitesse', 'deplacement'], 'secondary': ['force', 'dribble'], 'tertiary': ['passes']};
        
      case 'Défenseur central':
        return {'primary': ['marquage', 'tacles', 'force'], 'secondary': ['positionnement', 'stabilite_aerienne'], 'tertiary': ['agressivite']};
      case 'Latéral':
        return {'primary': ['vitesse', 'endurance', 'centres'], 'secondary': ['tacles', 'marquage'], 'tertiary': ['dribble']};
      case 'Milieu polyvalent': 
        return {'primary': ['passes', 'endurance', 'tacles'], 'secondary': ['deplacement', 'frappes_lointaines'], 'tertiary': ['finition']};
      case 'Milieu offensif':
        return {'primary': ['creativite', 'dribble', 'passes'], 'secondary': ['frappes_lointaines', 'deplacement'], 'tertiary': ['finition']};
      case 'Buteur': 
        return {'primary': ['finition', 'deplacement', 'sang_froid'], 'secondary': ['vitesse', 'stabilite_aerienne'], 'tertiary': ['force']};
      case 'Attaquant de soutien': 
        return {'primary': ['finition', 'deplacement', 'creativite'], 'secondary': ['passes', 'controle'], 'tertiary': ['dribble']};
      default:
        return {'primary': ['vitesse', 'endurance', 'force'], 'secondary': ['passes', 'creativite', 'finition', 'tacles'], 'tertiary': []};
    }
  }
}