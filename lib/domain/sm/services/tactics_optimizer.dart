// [lib/domain/sm/services/tactics_optimizer.dart]
import 'dart:math';
import 'package:gamemaster_hub/data/data_export.dart'; // Importation des models
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/domain/sm/repositories/instruction_attaque_sm_repository.dart';
import 'package:gamemaster_hub/domain/sm/repositories/instruction_defense_sm_repository.dart';
import 'package:gamemaster_hub/domain/sm/repositories/instruction_general_sm_repository.dart';

// --- CLASSES HELPER POUR L'OPTIMISATION ---

class OptimizedStyles {
  final Map<String, double> general; // name -> score
  final Map<String, double> attack;
  final Map<String, double> defense;
  OptimizedStyles(
      {required this.general, required this.attack, required this.defense});
}

class OptimizedTacticsResult {
  final String formation;
  final int? modeleId;
  final Map<int, int> joueurIdToRoleId; // joueur_id -> role_id
  final OptimizedStyles styles;
  final Map<String, _JoueurStatsComplet> elevenByPoste; // ex: "DC1" -> JoueurA

  OptimizedTacticsResult({
    required this.formation,
    required this.modeleId,
    required this.joueurIdToRoleId,
    required this.styles,
    required this.elevenByPoste,
  });
}

/// Classe interne pour fusionner les données joueur + stats
class _JoueurStatsComplet {
  final JoueurSm joueur;
  final dynamic stats; // Sera StatsJoueurSmModel ou StatsGardienSmModel
  final bool isGk;
  final double averageRating;
  final PosteEnum? preferredPoste; // Le *premier* poste de la liste

  _JoueurStatsComplet(
      {required this.joueur, required this.stats, required this.isGk})
      : averageRating = _calculateAverageRating(stats),
        preferredPoste = joueur.postes.isNotEmpty ? joueur.postes.first : null;

  static double _calculateAverageRating(dynamic stats) {
    if (stats == null) return 0.0;
    try {
      final Map<String, dynamic> json;
      if (stats is StatsJoueurSmModel) {
        json = stats.toMap();
      } else if (stats is StatsGardienSmModel) {
        json = stats.toMap();
      } else {
        return 0.0; // Type non reconnu
      }
      
      final values = json.values
          .whereType<num>()
          .map((v) => v.toDouble())
          .where((v) => v > 0)
          .toList();
      if (values.isEmpty) return 0.0;
      return values.reduce((a, b) => a + b) / values.length;
    } catch (_) {
      return 0.0;
    }
  }

  // ✅✅✅ LOGIQUE DE COMPATIBILITÉ CORRIGÉE ✅✅✅
  // Vérifie si un joueur peut jouer à un poste "de base" (ex: MOG)
  bool canPlayPoste(String basePoste) {
    // Map des postes logiques (ceux demandés) vers les postes réels (ceux du joueur)
    // C'est la liste de "compatibilité"
    // ✅ CORRIGÉ : N'utilise que des PosteEnum valides
    const Map<String, List<String>> compatibilityMap = {
      'G': ['G'],
      'DC': ['DC'],
      'DG': ['DG', 'DLG', 'DC'],
      'DD': ['DD', 'DLD', 'DC'],
      'DLG': ['DLG', 'DG', 'MG'],
      'DLD': ['DLD', 'DD', 'MD'],
      'MDC': ['MDC', 'MC', 'DC'], // Un MC/DC peut jouer MDC
      'MC': ['MC', 'MDC', 'MOC', 'MG', 'MD'], // Un MDC/MOC/MG/MD peut jouer MC
      'MOC': ['MOC', 'MC', 'MOG', 'MOD', 'BUC', 'BUG', 'BUD'],
      'MG': ['MG', 'MOG', 'DG', 'DLG'],
      'MD': ['MD', 'MOD', 'DD', 'DLD'],
      'MOG': ['MOG', 'MG', 'BUC', 'BUG', 'MOC'], // AG = MOG
      'MOD': ['MOD', 'MD', 'BUC', 'BUD', 'MOC'], // AD = MOD
      'BUC': ['BUC', 'BUG', 'BUD', 'MOG', 'MOD', 'MOC'],
      'BUG': ['BUG', 'BUC', 'MOG'],
      'BUD': ['BUD', 'BUC', 'MOD'],
    };
    
    // Prend la liste des postes compatibles pour le poste demandé (ex: "MOG" -> ["MOG", "MG", "BUC", "BUG", "MOC"])
    final List<String> compatibleEnumPostes = compatibilityMap[basePoste] ?? [basePoste];
    
    // Vérifie si *un seul* des postes du joueur (ex: "MOC") est dans cette liste
    for (final playerPoste in joueur.postes) {
      if (compatibleEnumPostes.contains(playerPoste.name)) {
        return true; // Trouvé ! Il peut jouer à ce poste.
      }
    }
    return false; // Non trouvé. (Ex: un "MC" ne peut pas jouer "DC")
  }
  
  // ✅✅✅ LOGIQUE DE POSTE PRÉFÉRÉ CORRIGÉE ✅✅✅
  // Vérifie si le poste *préféré* (le premier) du joueur correspond au poste demandé
  bool isPreferredPoste(String basePoste) {
    if (preferredPoste == null) return false;
    
    // Map de compatibilité plus stricte pour le *bonus*
    // Un "MC" qui joue "MDC" n'aura pas de bonus, mais n'est pas disqualifié.
    // ✅ CORRIGÉ : N'utilise que des PosteEnum valides
    const Map<String, List<String>> preferredMap = {
      'G': ['G'],
      'DC': ['DC'],
      'DG': ['DG', 'DLG'],
      'DD': ['DD', 'DLD'],
      'DLG': ['DLG', 'DG'],
      'DLD': ['DLD', 'DD'],
      'MDC': ['MDC'], // Seul un vrai MDC a le bonus
      'MC': ['MC'], // Seul un vrai MC a le bonus
      'MOC': ['MOC'],
      'MG': ['MG', 'MOG'],
      'MD': ['MD', 'MOD'],
      'MOG': ['MOG', 'MG'], // AG = MOG
      'MOD': ['MOD', 'MD'], // AD = MOD
      'BUC': ['BUC', 'BUG', 'BUD'],
      'BUG': ['BUG', 'BUC'],
      'BUD': ['BUD', 'BUC'],
    };
    
    final List<String> compatibleEnumPostes = preferredMap[basePoste] ?? [basePoste];
    return compatibleEnumPostes.contains(preferredPoste!.name);
  }


  bool isCorrectLateral(String basePoste) {
    if (preferredPoste == null) return true; // Ne peut pas pénaliser si pas de poste pref
    if (basePoste == 'DG') return preferredPoste!.name == 'DG' || preferredPoste!.name == 'DLG';
    if (basePoste == 'DD') return preferredPoste!.name == 'DD' || preferredPoste!.name == 'DLD';
    return true; // Pas un latéral, pas de pénalité
  }
  
  bool isCorrectWinger(String basePoste) {
    if (preferredPoste == null) return true;
    if (basePoste == 'MG' || basePoste == 'MOG') return preferredPoste!.name == 'MG' || preferredPoste!.name == 'MOG' || preferredPoste!.name == 'BUG';
    if (basePoste == 'MD' || basePoste == 'MOD') return preferredPoste!.name == 'MD' || preferredPoste!.name == 'MOD' || preferredPoste!.name == 'BUD';
    return true;
  }
  
  int getStat(String statName) {
    if (stats == null) return 0;
    try {
      final Map<String, dynamic> json;
      if (stats is StatsJoueurSmModel) {
        json = stats.toMap();
      } else if (stats is StatsGardienSmModel) {
        json = stats.toMap();
      } else {
        return 0; // Type non reconnu
      }
      
      final statKey = _statNameMapping[statName] ?? statName;
      
      if (json.containsKey(statKey)) {
        return (json[statKey] as num? ?? 0).toInt();
      }
    } catch (_) {
      // ignore
    }
    return 0;
  }

  // Mapper les noms de stats de la logique aux noms de la BDD/Model
  static const Map<String, String> _statNameMapping = {
    'frappes_lointaines': 'frappesLointaines',
    'passes_longues': 'passesLongues',
    'coups_francs': 'coupsFrancs',
    'stabilite_aerienne': 'stabiliteAerienne',
    'distance_parcourue': 'distanceParcourue',
    'sang_froid': 'sangFroid',
    'autorite_surface': 'autoriteSurface'
  };
}

class TacticsOptimizer {
  final JoueurSmRepository joueurRepo;
  final StatsJoueurSmRepository statsRepo;
  final StatsGardienSmRepository gardienRepo;
  final RoleModeleSmRepository roleRepo;
  final TactiqueModeleSmRepository tactiqueModeleRepo;

  final InstructionGeneralSmRepository instructionGeneralRepo;
  final InstructionAttaqueSmRepository instructionAttaqueRepo;
  final InstructionDefenseSmRepository instructionDefenseRepo;

  TacticsOptimizer({
    required this.joueurRepo,
    required this.statsRepo,
    required this.gardienRepo,
    required this.roleRepo,
    required this.tactiqueModeleRepo,
    required this.instructionGeneralRepo,
    required this.instructionAttaqueRepo,
    required this.instructionDefenseRepo,
  });

  /// 🎯 LOGIQUE PRINCIPALE D'OPTIMISATION 🎯
  Future<OptimizedTacticsResult> optimize({required int saveId}) async {
    // --- 1. RÉCUPÉRATION ET PRÉPARATION DES DONNÉES ---
    final allPlayers = await _getCombinedPlayerData(saveId);

    if (allPlayers.length < 11) {
      throw Exception("Vous devez avoir au moins 11 joueurs pour optimiser.");
    }

    final allFormationsPossibles = await tactiqueModeleRepo.getAllTactiques();
    
    final allRolesPossibles = await roleRepo.getAllRoles();

    // --- 2. 🎯 ETAPE 1: CHOISIR LA MEILLEURE FORMATION ---
    final bestFormationResult =
        _findBestFormation(allFormationsPossibles, allPlayers);

    final TactiqueModeleSm bestFormationModele = bestFormationResult['modele'];
    final List<_JoueurStatsComplet> startingEleven =
        bestFormationResult['eleven'];
    final Map<String, _JoueurStatsComplet> elevenByPoste =
        bestFormationResult['elevenByPoste'];

    // --- 3. 🎯 ETAPE 3: ATTRIBUER LES MEILLEURS RÔLES ---
    final Map<int, int> joueurToRole = _assignBestRoles(
      elevenByPoste,
      allRolesPossibles,
    );

    // --- 4. 🎯 ETAPE 4: DÉFINIR LES STYLES DE JEU ---
    final styles = _generateBestStyles(startingEleven);

    // --- 5. RETOURNER LE RÉSULTAT ---
    return OptimizedTacticsResult(
      formation: bestFormationModele.formation,
      modeleId: bestFormationModele.id,
      joueurIdToRoleId: joueurToRole,
      styles: styles,
      elevenByPoste: elevenByPoste,
    );
  }

  /// Helper pour fusionner joueurs et stats
  Future<List<_JoueurStatsComplet>> _getCombinedPlayerData(
      int saveId) async {
    final joueurs = await joueurRepo.getAllJoueurs(saveId);
    
    final statsList = await statsRepo.getAllStats(saveId);
    final gardienStatsList = await gardienRepo.getAllStats(saveId);

    final statsMap = {for (var s in statsList) s.joueurId: s};
    final gkStatsMap = {for (var s in gardienStatsList) s.joueurId: s};

    List<_JoueurStatsComplet> combinedList = [];
    for (final j in joueurs) {
      final isGk = j.postes.any((p) => p.name == 'G');
      final stats = isGk ? gkStatsMap[j.id] : statsMap[j.id]; 
      
      combinedList.add(_JoueurStatsComplet(joueur: j, stats: stats, isGk: isGk));
    }
    return combinedList;
  }


  /// LOGIQUE DE FORMATION
  Map<String, dynamic> _findBestFormation(
    List<TactiqueModeleSm> allFormations, // Vient de Supabase
    List<_JoueurStatsComplet> allPlayers,
  ) {
    if (allFormations.isEmpty) {
      // Fallback au cas où Supabase est vide
      allFormations.add(TactiqueModeleSm(id: 0, formation: '4-3-3'));
    }

    double bestFinalScore = -double.maxFinite; 
    TactiqueModeleSm bestModele = allFormations.first;
    List<_JoueurStatsComplet> bestEleven = [];
    Map<String, _JoueurStatsComplet> bestElevenByPoste = {};

    for (final modele in allFormations) {
      final postesKeys = _getPosteKeysForFormation(modele.formation);
      
      if (postesKeys.isEmpty) continue; // Formation non reconnue

      List<_JoueurStatsComplet> playerPool = List.from(allPlayers);
      List<_JoueurStatsComplet> currentEleven = [];
      Map<String, _JoueurStatsComplet> currentElevenByPoste = {};
      double startersScore = 0.0;
      double depthScore = 0.0;
      bool formationFeasible = true;

      // 1. Trouver les TITULAIRES
      for (final posteKey in postesKeys) {
        final basePoste = posteKey.replaceAll(RegExp(r'[0-9]'), ''); 

        _JoueurStatsComplet? bestPlayerForPoste = _findBestPlayerForPoste(
          playerPool, 
          basePoste
        );

        if (bestPlayerForPoste != null) {
          playerPool.remove(bestPlayerForPoste);
          currentEleven.add(bestPlayerForPoste);
          currentElevenByPoste[posteKey] = bestPlayerForPoste;
          startersScore += _calculatePlayerScore(bestPlayerForPoste, basePoste);
        } else {
          formationFeasible = false; // Ex: Pas de Gardien trouvé
          break;
        }
      }

      if (!formationFeasible) continue; // Cette formation est impossible

      // 2. Trouver les REMPLAÇANTS
      for (final posteKey in postesKeys) {
        final basePoste = posteKey.replaceAll(RegExp(r'[0-9]'), '');

        _JoueurStatsComplet? bestBackup = _findBestPlayerForPoste(
          playerPool, 
          basePoste
        );

        if (bestBackup != null) {
          playerPool.remove(bestBackup); 
          depthScore += _calculatePlayerScore(bestBackup, basePoste);
        } else {
          depthScore -= 150; // Pénalité lourde si pas de banc
        }
      }

      double totalFormationScore = startersScore + (depthScore * 0.5);

      if (totalFormationScore > bestFinalScore) {
        bestFinalScore = totalFormationScore;
        bestModele = modele;
        bestEleven = currentEleven;
        bestElevenByPoste = currentElevenByPoste;
      }
    }

    // ✅✅✅ CORRECTION DU BUG "TERRAIN VIDE" ✅✅✅
    // Si bestEleven est vide, cela signifie qu'AUCUNE formation n'a pu être
    // complétée (probablement pas de gardien).
    if (bestEleven.isEmpty) {
      throw Exception(
        "Impossible de former une équipe de 11 joueurs valides avec l'effectif actuel. "
        "Assurez-vous d'avoir au moins un Gardien (G) et suffisamment de défenseurs/milieux/attaquants."
      );
    }
    // ✅✅✅ FIN CORRECTION ✅✅✅

    return {
      'modele': bestModele,
      'eleven': bestEleven,
      'elevenByPoste': bestElevenByPoste,
    };
  }

  _JoueurStatsComplet? _findBestPlayerForPoste(List<_JoueurStatsComplet> pool, String basePoste) {
    if (pool.isEmpty) return null;

    _JoueurStatsComplet? bestPlayer;
    double bestScore = -double.maxFinite;

    for (final player in pool) {
      double score = _calculatePlayerScore(player, basePoste);
      if (score > bestScore) {
        bestScore = score;
        bestPlayer = player;
      }
    }
    
    // Si le meilleur score est -1000, personne ne peut jouer à ce poste
    if (bestScore <= -1000) {
      return null;
    }
    
    return bestPlayer;
  }

  /// CALUL DU SCORE D'UN JOUEUR POUR UN POSTE
  double _calculatePlayerScore(_JoueurStatsComplet player, String basePoste) {
    
    // 1. Handle GK
    if (basePoste == 'G') {
      return player.isGk ? player.averageRating * 1.5 : -1000;
    }
    if (player.isGk) {
      return -1000; // GK can't be field player
    }

    // 2. ✅ DISQUALIFICATION (This is the key fix)
    if (!player.canPlayPoste(basePoste)) {
      return -1000; // DISQUALIFIED. Cannot play this position at all.
    }

    // 3. Calculate score based on *key stats* for the role
    final keyStats = _getKeyStatsForPoste(basePoste);
    double baseScore = 0.0;
    
    if (keyStats.isEmpty) {
      baseScore = player.averageRating; // Fallback si le poste n'est pas mappé
    } else {
      for (final statName in keyStats) {
        baseScore += player.getStat(statName);
      }
      baseScore = baseScore / keyStats.length;
    }


    // 4. ✅ CORRIGÉ : Application des bonus/malus
    // Priorité au statut, PUIS au poste préféré
    
    // Malus for playing on the wrong side (even if compatible)
    if (!player.isCorrectLateral(basePoste) || !player.isCorrectWinger(basePoste)) {
        baseScore *= 0.6; // 40% penalty
    }
    
    // Bonus pour poste préféré (le premier de la liste)
    if (player.isPreferredPoste(basePoste)) {
      baseScore *= 1.5; // Bonus de 50%
    }
    
    // Pondération du statut (PRIORITAIRE)
    switch (player.joueur.status) {
      case StatusEnum.Titulaire:
        baseScore *= 2.0; // Bonus de 100%
        break;
      case StatusEnum.Remplacant:
        baseScore *= 0.8; // Pénalité de 20%
        break;
      case StatusEnum.Preter:
      case StatusEnum.Vendre:
        return -1000; // DISQUALIFIED
    }

    // 5. Apply potential bonus
    double potentiel = player.joueur.potentiel.toDouble();
    double niveauActuel = player.joueur.niveauActuel.toDouble();
    if (potentiel < niveauActuel) potentiel = niveauActuel;
    
    double potentielMargin = potentiel - niveauActuel;
    if (potentielMargin > 0) {
      double potentialBonus = 1 + (potentielMargin / 200);
      baseScore *= potentialBonus;
    }

    return baseScore;
  }

  /// Mappe les POSTES aux stats clés
  List<String> _getKeyStatsForPoste(String poste) {
    switch (poste) {
      case 'G':
        return ['arrets', 'positionnement', 'duels', 'captation', 'autorite_surface'];
      case 'DC':
        return ['marquage', 'tacles', 'force', 'positionnement', 'stabilite_aerienne'];
      case 'DG':
      case 'DD':
      case 'DLG':
      case 'DLD':
        return ['vitesse', 'endurance', 'centres', 'tacles', 'marquage'];
      case 'MDC':
        return ['tacles', 'endurance', 'agressivite', 'passes', 'positionnement'];
      case 'MC':
        return ['passes', 'creativite', 'controle', 'endurance', 'deplacement'];
      case 'MOC':
        return ['creativite', 'dribble', 'frappes_lointaines', 'passes', 'deplacement'];
      case 'MG':
      case 'MD':
      case 'MOG': // AG = MOG
      case 'MOD': // AD = MOD
        return ['vitesse', 'dribble', 'centres', 'creativite', 'finition'];
      case 'BUC':
      case 'BUG':
      case 'BUD':
        return ['finition', 'deplacement', 'sang_froid', 'vitesse', 'stabilite_aerienne'];
      default:
        // Fallback
        return ['vitesse', 'endurance', 'force'];
    }
  }

  /// 🎯 ETAPE 3: Logique d'assignation des rôles
  Map<int, int> _assignBestRoles(
    Map<String, _JoueurStatsComplet> elevenByPoste,
    List<RoleModeleSm> allRoles,
  ) {
    final Map<int, int> joueurToRole = {};

    for (final entry in elevenByPoste.entries) {
      final String poste = entry.key.replaceAll(RegExp(r'[0-9]'), ''); // 'DC1' -> 'DC'
      final _JoueurStatsComplet player = entry.value;

      final possibleRoles = allRoles.where((r) => r.poste == poste).toList();
      if (possibleRoles.isEmpty) continue;

      RoleModeleSm bestRole = possibleRoles.first;
      double bestScore = -1.0;

      for (final role in possibleRoles) {
        double currentScore = 0.0;
        final keyStats = _getKeyStatsForRole(role.role); 
        
        // MODIFICATION : Calcul de la moyenne au lieu de la somme
        if (keyStats.isNotEmpty) {
           for (final statName in keyStats) {
            currentScore += player.getStat(statName);
          }
          currentScore = currentScore / keyStats.length; // Calcul de la moyenne
        }
        // FIN MODIFICATION

        if (currentScore > bestScore) {
          bestScore = currentScore;
          bestRole = role;
        }
      }
      joueurToRole[player.joueur.id] = bestRole.id;
    }
    return joueurToRole;
  }

  /// ✅ LOGIQUE DE STYLES
  OptimizedStyles _generateBestStyles(List<_JoueurStatsComplet> eleven) {
    
    // 1. Calculer les moyennes de l'équipe
    final stats = _calculateTeamAverages(eleven);

    // 2. Obtenir le meilleur choix pour chaque catégorie
    final Map<String, double> general = {
      ..._getBestLargeur(stats),
      ..._getBestMentalite(stats),
      ..._getBestTempo(stats),
      ..._getBestFluidite(stats),
      ..._getBestRythmeTravail(stats),
      ..._getBestCreativite(stats),
    };
    
    final Map<String, double> attack = {
      ..._getBestStylePasse(stats),
      ..._getBestStyleAttaque(stats),
      ..._getBestAttaquants(stats),
      ..._getBestJeuLarge(stats),
      ..._getBestJeuConstruction(stats),
      ..._getBestContreAttaque(stats),
    };
    
    final Map<String, double> defense = {
      ..._getBestPressing(stats),
      ..._getBestStyleTacle(stats),
      ..._getBestLigneDefensive(stats),
      ..._getBestGardienLibero(stats),
      ..._getBestPerteTemps(stats),
    };

    return OptimizedStyles(general: general, attack: attack, defense: defense);
  }

  // --- Helpers pour le calcul des moyennes ---
  Map<String, double> _calculateTeamAverages(List<_JoueurStatsComplet> eleven) {
    Map<String, double> averages = {
      'vitesse': 0, 'endurance': 0, 'agressivite': 0, 'creativite': 0,
      'passes': 0, 'finition': 0, 'tacles': 0, 'positionnementDef': 0,
      'deplacementOff': 0, 'passesLongues': 0, 'centres': 0,
      'controle': 0, 'dribble': 0, 'sangFroid': 0, 'frappesLointaines': 0,
      'gk_distribution': 0, 'gk_arrets': 0, 'gk_vitesse': 0
    };
    int fieldPlayers = 0;
    
    for (final p in eleven) {
      if (p.isGk) {
        averages['gk_distribution'] = (averages['gk_distribution'] ?? 0) + p.getStat('distribution');
        averages['gk_arrets'] = (averages['gk_arrets'] ?? 0) + p.getStat('arrets');
        averages['gk_vitesse'] = (averages['gk_vitesse'] ?? 0) + p.getStat('vitesse');
      } else {
        averages['vitesse'] = (averages['vitesse'] ?? 0) + p.getStat('vitesse');
        averages['endurance'] = (averages['endurance'] ?? 0) + p.getStat('endurance');
        averages['agressivite'] = (averages['agressivite'] ?? 0) + p.getStat('agressivite');
        averages['creativite'] = (averages['creativite'] ?? 0) + p.getStat('creativite');
        averages['passes'] = (averages['passes'] ?? 0) + p.getStat('passes');
        averages['finition'] = (averages['finition'] ?? 0) + p.getStat('finition');
        averages['tacles'] = (averages['tacles'] ?? 0) + p.getStat('tacles');
        averages['positionnementDef'] = (averages['positionnementDef'] ?? 0) + p.getStat('positionnement');
        averages['deplacementOff'] = (averages['deplacementOff'] ?? 0) + p.getStat('deplacement');
        averages['passesLongues'] = (averages['passesLongues'] ?? 0) + p.getStat('passes_longues');
        averages['centres'] = (averages['centres'] ?? 0) + p.getStat('centres');
        averages['controle'] = (averages['controle'] ?? 0) + p.getStat('controle');
        averages['dribble'] = (averages['dribble'] ?? 0) + p.getStat('dribble');
        averages['sangFroid'] = (averages['sangFroid'] ?? 0) + p.getStat('sang_froid');
        averages['frappesLointaines'] = (averages['frappesLointaines'] ?? 0) + p.getStat('frappes_lointaines');
        fieldPlayers++;
      }
    }

    if (fieldPlayers > 0) {
      averages.forEach((key, value) {
        if (!key.startsWith('gk_')) {
          averages[key] = value / fieldPlayers;
        }
      });
    }
    return averages;
  }

  // --- Helpers pour la sélection de style (1 par catégorie) ---
  
  Map<String, double> _getBestLargeur(Map<String, double> stats) {
    double avgCentres = stats['centres'] ?? 50;
    if (avgCentres > 65) return {'Largeur: Jeu large': 1.0};
    if (avgCentres < 45) return {'Largeur: Étroit': 1.0};
    return {'Largeur: Normal': 1.0};
  }

  Map<String, double> _getBestMentalite(Map<String, double> stats) {
    double avgCreativite = stats['creativite'] ?? 50;
    double avgFinition = stats['finition'] ?? 50;
    double avgTacles = stats['tacles'] ?? 50;
    if (avgCreativite > 75 && avgFinition > 70) return {'Mentalité: Très offensive': 1.0};
    if (avgCreativite > 60 || avgFinition > 60) return {'Mentalité: Offensive': 1.0};
    if (avgTacles > 75 && avgCreativite < 40) return {'Mentalité: Très défensive': 1.0};
    if (avgTacles > 60 && avgCreativite < 50) return {'Mentalité: Défensive': 1.0};
    return {'Mentalité: Normal': 1.0};
  }

  Map<String, double> _getBestTempo(Map<String, double> stats) {
    double avgVitesse = stats['vitesse'] ?? 50;
    if (avgVitesse > 65) return {'Tempo: Rapide': 1.0};
    if (avgVitesse < 45) return {'Tempo: Lent': 1.0};
    return {'Tempo: Normal': 1.0};
  }
  
  Map<String, double> _getBestFluidite(Map<String, double> stats) {
    double avgDeplacement = stats['deplacementOff'] ?? 50;
    if (avgDeplacement > 65) return {'Fluidité de la formation: Aventureux': 1.0};
    if (avgDeplacement < 45) return {'Fluidité de la formation: Discipliné': 1.0};
    return {'Fluidité de la formation: Normal': 1.0};
  }
  
  Map<String, double> _getBestRythmeTravail(Map<String, double> stats) {
    double avgEndurance = stats['endurance'] ?? 50;
    if (avgEndurance > 65) return {'Rythme de travail: Rapide': 1.0};
    if (avgEndurance < 45) return {'Rythme de travail: Lent': 1.0};
    return {'Rythme de travail: Normal': 1.0};
  }

  Map<String, double> _getBestCreativite(Map<String, double> stats) {
    double avgCreativite = stats['creativite'] ?? 50;
    if (avgCreativite > 65) return {'Créativité: Audacieux': 1.0};
    if (avgCreativite < 45) return {'Créativité: Prudent': 1.0};
    return {'Créativité: Équilibré': 1.0};
  }

  Map<String, double> _getBestStylePasse(Map<String, double> stats) {
    double avgPasses = stats['passes'] ?? 50;
    double avgPassesLongues = stats['passesLongues'] ?? 50;
    if (avgPassesLongues > 70 && avgPasses < 60) return {'Style de passe: Ballon longs': 1.0};
    if (avgPasses > 70 && avgPassesLongues < 60) return {'Style de passe: Court': 1.0};
    if (avgPasses > 60 && avgPassesLongues > 60) return {'Style de passe: Direct': 1.0};
    return {'Style de passe: Polyvalent': 1.0};
  }
  
  Map<String, double> _getBestStyleAttaque(Map<String, double> stats) {
    double avgDribble = stats['dribble'] ?? 50;
    double avgCentres = stats['centres'] ?? 50;
    if(avgDribble > 65 && avgCentres > 65) return {'Style d\'attaque: Sur les deux ailes': 1.0};
    if(avgDribble > 60) return {'Style d\'attaque: Par l\'axe': 1.0};
    return {'Style d\'attaque: Polyvalent': 1.0};
  }

  Map<String, double> _getBestAttaquants(Map<String, double> stats) {
    double avgFinition = stats['finition'] ?? 50;
    double avgFrappesLointaines = stats['frappesLointaines'] ?? 50;
    if (avgFinition > 65) return {'Attaquants: Jouer le ballon dans la surface': 1.0};
    if (avgFrappesLointaines > 65) return {'Attaquants: Tirer à vue': 1.0};
    return {'Attaquants: Polyvalents': 1.0};
  }
  
  Map<String, double> _getBestJeuLarge(Map<String, double> stats) {
    double avgCentres = stats['centres'] ?? 50;
    if (avgCentres > 65) return {'Jeu large: Centres de la ligne de touche': 1.0};
    return {'Jeu large: Polyvalent': 1.0};
  }

  Map<String, double> _getBestJeuConstruction(Map<String, double> stats) {
    double avgControle = stats['controle'] ?? 50;
    if (avgControle > 65) return {'Jeu en contruction: Lent': 1.0}; 
    if (avgControle < 45) return {'Jeu en contruction: Rapide': 1.0};
    return {'Jeu en contruction: Normal': 1.0};
  }
  
  Map<String, double> _getBestContreAttaque(Map<String, double> stats) {
    double avgVitesse = stats['vitesse'] ?? 50;
    if (avgVitesse > 65) return {'Contre-attaque: Oui': 1.0};
    return {'Contre-attaque: Non': 1.0};
  }
  
  Map<String, double> _getBestPressing(Map<String, double> stats) {
    double avgEndurance = stats['endurance'] ?? 50;
    if (avgEndurance > 70) return {'Pressing: Partout': 1.0};
    if (avgEndurance > 55) return {'Pressing: Propre moitié de terrain': 1.0};
    return {'Pressing: Propre surface de réparation': 1.0};
  }

  Map<String, double> _getBestStyleTacle(Map<String, double> stats) {
    double avgAgressivite = stats['agressivite'] ?? 50;
    double avgTacles = stats['tacles'] ?? 50;
    if (avgAgressivite > 75 && avgTacles > 65) return {'Style tacle: Agressif': 1.0};
    if (avgAgressivite > 65) return {'Style tacle: Rugeux': 1.0}; // "Rugeux"
    return {'Style tacle: Normal': 1.0};
  }

  Map<String, double> _getBestLigneDefensive(Map<String, double> stats) {
    double avgVitesseDef = stats['vitesse'] ?? 50; 
    if (avgVitesseDef > 65) return {'Ligne défensive: Haut': 1.0};
    if (avgVitesseDef < 45) return {'Ligne défensive: Bas': 1.0};
    return {'Ligne défensive: Normal': 1.0};
  }
  
  Map<String, double> _getBestGardienLibero(Map<String, double> stats) {
    double avgGkVit = stats['gk_vitesse'] ?? 50;
    if (avgGkVit > 60) return {'Gardien libéro: Oui': 1.0};
    return {'Gardien libéro: Non': 1.0};
  }
  
  Map<String, double> _getBestPerteTemps(Map<String, double> stats) {
    double avgMentalite = (stats['creativite'] ?? 50) + (stats['finition'] ?? 50);
    if (avgMentalite > 130) return {'Perte de temps: Faible': 1.0};
    if (avgMentalite < 100) return {'Perte de temps: Haut': 1.0};
    return {'Perte de temps: Normal': 1.0};
  }


  // --- MAPPINGS DE DONNÉES (Logique métier) ---

  // ✅✅✅ CARTE CANONIQUE DES FORMATIONS ✅✅✅
  List<String> _getPosteKeysForFormation(String formation) {
    // Utilise les clés de la base (ex: MOG, BUC) et des numéros pour les doublons
    final map = {
      '4-4-2': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MG', 'MC1', 'MC2', 'MD', 'BUC1', 'BUC2'],
      '4-3-1-2': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MC1', 'MC2', 'MC3', 'MOC', 'BUC1', 'BUC2'],
      '4-2-3-1': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MDC1', 'MDC2', 'MOG', 'MOC', 'MOD', 'BUC'],
      '4-2-2-2': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MDC1', 'MDC2', 'MOC1', 'MOC2', 'BUC1', 'BUC2'],
      '4-3-3': ['G', 'DG', 'DC1', 'DC2', 'DD', 'MC1', 'MC2', 'MC3', 'MOG', 'MOD', 'BUC'],
      '3-4-3': ['G', 'DC1', 'DC2', 'DC3', 'MG', 'MC1', 'MC2', 'MD', 'MOG', 'MOD', 'BUC'],
      '3-5-2': ['G', 'DC1', 'DC2', 'DC3', 'MG', 'MDC', 'MC1', 'MC2', 'MD', 'BUC1', 'BUC2'],
      '3-3-3-1': ['G', 'DC1', 'DC2', 'DC3', 'MDC1', 'MDC2', 'MDC3', 'MOG', 'MOC', 'MOD', 'BUC'],
      '3-2-4-1': ['G', 'DC1', 'DC2', 'DC3', 'MDC1', 'MDC2', 'MOG', 'MOC1', 'MOC2', 'MOD', 'BUC'],
    };
    return map[formation] ?? map['4-3-3']!; // Fallback sur 4-3-3
  }

  List<String> _getKeyStatsForRole(String roleName) {
    // Mappage RÔLE -> STATS (pour ETAPE 3)
    switch (roleName) {
      case 'Gardien':
        return ['arrets', 'positionnement', 'duels'];
      case 'Défenseur central':
        return ['marquage', 'tacles', 'force'];
      case 'Défenseur relanceur':
        return ['marquage', 'passes', 'controle'];
      case 'Latéral':
        return ['vitesse', 'endurance', 'centres'];
      case 'Milieu récupérateur':
        return ['tacles', 'endurance', 'agressivite'];
      case 'Meneur de jeu':
        return ['passes', 'creativite', 'controle'];
      case 'Milieu offensif':
        return ['creativite', 'dribble', 'frappes_lointaines'];
      case 'Ailier':
        return ['vitesse', 'dribble', 'centres'];
      case 'Buteur':
        return ['finition', 'deplacement', 'sang_froid'];
      default:
        return ['vitesse', 'endurance', 'force'];
    }
  }
}

extension _Precision on double {
  double toPrecision(int fractionDigits) {
    double mod = pow(10.0, fractionDigits).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}