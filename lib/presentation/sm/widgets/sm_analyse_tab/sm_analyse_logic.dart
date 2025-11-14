import 'package:collection/collection.dart';
import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc_export.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/tactics/tactics_bloc_export.dart';

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

class _AnalyseHelper {
  static const Map<String, String> _statNameMapping = {
    'frappes_lointaines': 'frappesLointaines',
    'passes_longues': 'passesLongues',
    'coups_francs': 'coupsFrancs',
    'stabilite_aerienne': 'stabiliteAerienne',
    'distance_parcourue': 'distanceParcourue',
    'sang_froid': 'sangFroid',
    'autorite_surface': 'autoriteSurface'
  };

  static int getStat(JoueurSmWithStats player, String statName) {
    if (player.stats == null) return 0;
    
    final statKey = _statNameMapping[statName] ?? statName;
    
    try {
      if (player.stats is StatsJoueurSmModel || player.stats is StatsJoueurSm) {
        final statsMap = (player.stats as StatsJoueurSm).toJson();
        if (statsMap.containsKey(statKey)) {
          return (statsMap[statKey] as num? ?? 0).toInt();
        }
      } else if (player.stats is StatsGardienSmModel || player.stats is StatsGardienSm) {
         final statsMap = (player.stats as StatsGardienSm).toJson();
         if (statsMap.containsKey(statKey)) {
          return (statsMap[statKey] as num? ?? 0).toInt();
        }
      }
    } catch (_) {
    }
    return 0;
  }
  
  static String _mapSpecificPosteGroup(PosteEnum poste) {
    switch (poste) {
      case PosteEnum.G:
        return 'G';
      case PosteEnum.DC:
        return 'DC';
      case PosteEnum.DG:
      case PosteEnum.DLG:
        return 'DL';
      case PosteEnum.DD:
      case PosteEnum.DLD:
        return 'DR';
      case PosteEnum.MDC:
        return 'MDC';
      case PosteEnum.MC:
        return 'MC';
      case PosteEnum.MOC:
        return 'MOC';
      case PosteEnum.MG:
      case PosteEnum.MOG:
        return 'ML'; 
      case PosteEnum.MD:
      case PosteEnum.MOD:
        return 'MR'; 
      case PosteEnum.BUC:
      case PosteEnum.BUG:
      case PosteEnum.BUD:
        return 'BU'; 
    }
  }

  static bool isCompatible(JoueurSm joueur, String basePoste) {
    const Map<String, List<String>> compatibilityMap = {
      'G': ['G'],
      'DC': ['DC'],
      'DG': ['DG', 'DLG', 'DC'],
      'DD': ['DD', 'DLD', 'DC'],
      'DLG': ['DLG', 'DG', 'MG'],
      'DLD': ['DLD', 'DD', 'MD'],
      'MDC': ['MDC', 'MC', 'DC'], 
      'MC': ['MC', 'MDC', 'MOC', 'MG', 'MD'], 
      'MOC': ['MOC', 'MC', 'MOG', 'MOD', 'BUC', 'BUG', 'BUD'],
      'MG': ['MG', 'MOG', 'DG', 'DLG'],
      'MD': ['MD', 'MOD', 'DD', 'DLD'],
      'MOG': ['MOG', 'MG', 'BUC', 'BUG', 'MOC'], 
      'MOD': ['MOD', 'MD', 'BUC', 'BUD', 'MOC'],
      'BUC': ['BUC', 'BUG', 'BUD', 'MOG', 'MOD', 'MOC'],
      'BUG': ['BUG', 'BUC', 'MOG'],
      'BUD': ['BUD', 'BUC', 'MOD'],
    };
    final List<String> compatibleEnumPostes = compatibilityMap[basePoste] ?? [basePoste];
    for (final playerPoste in joueur.postes) {
      if (compatibleEnumPostes.contains(playerPoste.name)) {
        return true; 
      }
    }
    return false;
  }

  static bool isPreferredPoste(JoueurSm joueur, String basePoste) {
    if (joueur.postes.isEmpty) return false;
    final preferredPoste = joueur.postes.first.name;

    const Map<String, List<String>> preferredMap = {
      'G': ['G'],
      'DC': ['DC'],
      'DG': ['DG', 'DLG'],
      'DD': ['DD', 'DLD'],
      'DLG': ['DLG', 'DG'],
      'DLD': ['DLD', 'DD'],
      'MDC': ['MDC'], 
      'MC': ['MC'],
      'MOC': ['MOC'],
      'MG': ['MG', 'MOG'],
      'MD': ['MD', 'MOD'],
      'MOG': ['MOG', 'MG'], 
      'MOD': ['MOD', 'MD'], 
      'BUC': ['BUC', 'BUG', 'BUD'],
      'BUG': ['BUG', 'BUC'],
      'BUD': ['BUD', 'BUC'],
    };
    
    final List<String> compatibleEnumPostes = preferredMap[basePoste] ?? [basePoste];
    return compatibleEnumPostes.contains(preferredPoste);
  }
}

class SMAnalyseLogic {
  
  static AnalyseResult analyser({
    required JoueursSmLoaded joueursState,
    required TacticsSmState tacticsState,
  }) {
    final forces = <String>[];
    final faiblesses = <String>[];
    final manques = <String>[];

    final allPlayers = joueursState.joueurs;
    if (allPlayers.isEmpty) {
      manques.add("Vous n'avez aucun joueur dans cet effectif.");
      return AnalyseResult(forces: forces, faiblesses: faiblesses, manques: manques);
    }

    double totalAge = 0;
    int nbJeunes = 0;
    int nbPrime = 0; 
    int nbVieux = 0; 
    double totalRating = 0;
    int nbStars = 0;
    int nbPotentiel = 0;
    
    final Map<String, int> specificPosteCounts = {
      'G': 0, 'DC': 0, 'DL': 0, 'DR': 0, 'MDC': 0, 'MC': 0, 'MOC': 0, 'ML': 0, 'MR': 0, 'BU': 0,
    };

    for (final j in allPlayers) {
      final joueur = j.joueur;
      totalAge += joueur.age;
      totalRating += joueur.niveauActuel;

      if (joueur.age < 23) nbJeunes++;
      else if (joueur.age >= 24 && joueur.age <= 29) nbPrime++;
      else if (joueur.age > 29) nbVieux++; // Changé à > 29

      if (joueur.niveauActuel >= 85) nbStars++;
      if (joueur.potentiel >= 88) nbPotentiel++;

      if (joueur.postes.isNotEmpty) {
        final poste = joueur.postes.first;
        final posteGroup = _AnalyseHelper._mapSpecificPosteGroup(poste);
        specificPosteCounts[posteGroup] = (specificPosteCounts[posteGroup] ?? 0) + 1;
      }
    }

    final total = allPlayers.length;
    final avgAge = totalAge / total;
    final avgRating = totalRating / total;

    if (avgRating >= 78) forces.add("Effectif d'un excellent niveau général (${avgRating.toStringAsFixed(0)} moy).");
    if (avgRating < 70) faiblesses.add("Niveau général de l'effectif faible (${avgRating.toStringAsFixed(0)} moy).");
    
    if (nbStars > 0) forces.add("Possède $nbStars joueur(s) star(s) (Note > 85).");
    else faiblesses.add("Manque de joueurs d'impact (Note > 85).");

    if (nbPotentiel > 0) forces.add("$nbPotentiel joueur(s) à très haut potentiel (Pot > 88).");
    else faiblesses.add("L'effectif manque de futurs talents (Pot > 88).");

    final pctVieux = nbVieux / total;
    final pctJeunes = nbJeunes / total;

    if (pctVieux > 0.4) {
      forces.add("Effectif très expérimenté (${avgAge.toStringAsFixed(1)} ans moy).");
      faiblesses.add("Effectif vieillissant. Risque de déclin et faible valeur de revente.");
      manques.add("Besoin de recruter des jeunes talents (< 23 ans) pour rajeunir l'équipe.");
    } else if (pctJeunes > 0.5) { 
      forces.add("Énorme potentiel de développement (${avgAge.toStringAsFixed(1)} ans moy).");
      faiblesses.add("Effectif très inexpérimenté. Manque de stabilité et de gestion.");
      manques.add("Besoin de joueurs d'expérience (28+ ans) pour encadrer les jeunes.");
    } else {
      forces.add("Bon équilibre d'âge dans l'effectif (${avgAge.toStringAsFixed(1)} ans moy).");
    }

    if (nbPrime / total < 0.25 && pctVieux < 0.4 && pctJeunes < 0.5) {
      faiblesses.add("Manque de joueurs au sommet de leur forme (24-29 ans).");
    }

    final Map<String, int> minDepth = {
      'G': 2, 'DC': 4, 'DL': 2, 'DR': 2, 'MDC': 3, 'MC': 4, 'MOC': 2, 'ML': 2, 'MR': 2, 'BU': 3
    };

    minDepth.forEach((poste, min) {
      final current = specificPosteCounts[poste] ?? 0;
      if (current == 0 && (poste == 'G' || poste == 'DC' || poste == 'MC' || poste == 'BU')) {
         manques.add("Manque critique : Aucun joueur au poste de $poste.");
      } else if (current < min) {
         manques.add("Manque de profondeur au poste de $poste (Actuel: $current, Requis: $min).");
      }
    });


    if (tacticsState.assignedPlayersByPoste.isEmpty) {
      manques.add("Aucune tactique n'a été optimisée ou chargée.");
      return AnalyseResult(forces: forces, faiblesses: faiblesses, manques: manques);
    }

    final titularIds = tacticsState.assignedPlayersByPoste.values.whereNotNull().map((p) => p.joueur.id).toSet();
    final eleven = allPlayers.where((p) => titularIds.contains(p.joueur.id)).toList();
    final benchPlayers = allPlayers.where((p) => !titularIds.contains(p.joueur.id)).toList();

    double totalRatingTitulaires = 0;
    double totalRatingBench = 0;

    for (final j in eleven) {
      totalRatingTitulaires += j.joueur.niveauActuel;
    }
    for (final j in benchPlayers) {
      totalRatingBench += j.joueur.niveauActuel;
    }

    final avgRatingTitulaires = totalRatingTitulaires / (eleven.isEmpty ? 1 : eleven.length);
    final avgRatingBench = totalRatingBench / (benchPlayers.isEmpty ? 1 : benchPlayers.length);

    if (avgRatingTitulaires > 0) forces.add("Onze de départ compétitif (Note moy: ${avgRatingTitulaires.toStringAsFixed(0)}).");

    if (avgRatingBench < 68 && avgRatingBench > 0) {
      faiblesses.add("Banc de touche très faible (Note moy: ${avgRatingBench.toStringAsFixed(0)}).");
    }

    if (avgRatingTitulaires - avgRatingBench > 10 && avgRatingBench > 0) {
      faiblesses.add("Gros écart de niveau (${avgRatingTitulaires.toStringAsFixed(0)} vs ${avgRatingBench.toStringAsFixed(0)}) entre titulaires et banc.");
      manques.add("Besoin de recruter des remplaçants de meilleur niveau.");
    }

    final formation = tacticsState.selectedFormation;
    forces.add("Analyse basée sur la formation : $formation");

    double avgPassesLongues = 0;
    double avgEndurance = 0;
    double avgVitesseDef = 0;
    double avgAttaque = 0;
    double avgDefense = 0;
    int defCount = 0;
    int attCount = 0;
    int fieldPlayersCount = 0;
    
    tacticsState.assignedPlayersByPoste.forEach((posteKey, player) {
      if (player == null) return;
      final basePoste = posteKey.replaceAll(RegExp(r'[0-9]'), '');
      
      if (!_AnalyseHelper.isCompatible(player.joueur, basePoste)) {
        faiblesses.add("${player.joueur.nom} joue totalement hors-position (en $basePoste).");
      } else if (!_AnalyseHelper.isPreferredPoste(player.joueur, basePoste)) {
         faiblesses.add("${player.joueur.nom} joue à un poste non-préférentiel (en $basePoste).");
      }

      if (player.joueur.niveauActuel < 72) {
         faiblesses.add("${player.joueur.nom} (Note ${player.joueur.niveauActuel}) est un point faible potentiel au poste de $posteKey.");
      }
    });

    for (final j in eleven) {
      if(j.joueur.postes.first.name == 'G') continue;
      
      fieldPlayersCount++;
      avgEndurance += _AnalyseHelper.getStat(j, 'endurance');
      avgPassesLongues += _AnalyseHelper.getStat(j, 'passes_longues');
      
      final basePosteCat = _AnalyseHelper._mapSpecificPosteGroup(j.joueur.postes.first);
      if (basePosteCat == 'DC' || basePosteCat == 'DL' || basePosteCat == 'DR' || basePosteCat == 'MDC') {
        avgVitesseDef += _AnalyseHelper.getStat(j, 'vitesse');
        avgDefense += (
            _AnalyseHelper.getStat(j, 'marquage') + 
            _AnalyseHelper.getStat(j, 'tacles') + 
            _AnalyseHelper.getStat(j, 'positionnement')
        ) / 3.0;
        defCount++;
      }
      if (basePosteCat == 'BU' || basePosteCat == 'MOC' || basePosteCat == 'ML' || basePosteCat == 'MR') {
         avgAttaque += (
            _AnalyseHelper.getStat(j, 'finition') + 
            _AnalyseHelper.getStat(j, 'frappes_lointaines') + 
            _AnalyseHelper.getStat(j, 'deplacement')
        ) / 3.0;
        attCount++;
      }
    }
    
    if (fieldPlayersCount > 0) {
      avgEndurance /= fieldPlayersCount;
      avgPassesLongues /= fieldPlayersCount;
    }
    if (defCount > 0) {
      avgVitesseDef /= defCount;
      avgDefense /= defCount;
    }
     if (attCount > 0) {
      avgAttaque /= attCount;
    }

    if (formation.startsWith('3-')) {
      if (avgDefense < 70 && avgDefense > 0) {
        faiblesses.add("Une défense à 3 ($formation) est risquée avec une note défensive moyenne de ${avgDefense.toStringAsFixed(0)}.");
      } else if (avgDefense >= 75) {
        forces.add("La défense à 3 ($formation) semble solide (${avgDefense.toStringAsFixed(0)} moy).");
      }
    }

    final stylesGen = tacticsState.stylesGeneral;
    final stylesAtt = tacticsState.stylesAttack;
    final stylesDef = tacticsState.stylesDefense;

    if (stylesGen.keys.any((k) => k.contains('Très offensive'))) {
      if (avgAttaque < 75 && avgAttaque > 0) {
        faiblesses.add("Style 'Très offensif' choisi, mais l'attaque des titulaires (${avgAttaque.toStringAsFixed(0)}) n'est pas d'élite.");
      } else if (avgAttaque >= 75) {
        forces.add("Le style 'Très offensif' correspond bien à la note d'attaque élevée (${avgAttaque.toStringAsFixed(0)}).");
      }
    }

    if (stylesAtt.keys.any((k) => k.contains('Ballon longs'))) {
      if (avgPassesLongues < 60 && avgPassesLongues > 0) {
        faiblesses.add("Style 'Balles longues' choisi, mais la moyenne de passes longues des titulaires (${avgPassesLongues.toStringAsFixed(0)}) est faible.");
      }
    }

    if (stylesDef.keys.any((k) => k.contains('Pressing: Partout'))) {
      if (avgEndurance < 65 && avgEndurance > 0) {
        faiblesses.add("Le 'Pressing Partout' risque d'épuiser l'équipe (Endurance moy: ${avgEndurance.toStringAsFixed(0)}).");
      } else if (avgEndurance >= 75) {
        forces.add("L'endurance élevée (${avgEndurance.toStringAsFixed(0)}) est parfaite pour le 'Pressing Partout'.");
      }
    }

    if (stylesDef.keys.any((k) => k.contains('Ligne défensive: Haut'))) {
      if (avgVitesseDef < 60 && avgVitesseDef > 0) {
        faiblesses.add("Ligne défensive haute risquée (Vitesse défenseurs: ${avgVitesseDef.toStringAsFixed(0)}).");
      }
    }

    return AnalyseResult(
        forces: forces, faiblesses: faiblesses, manques: manques);
  }
}