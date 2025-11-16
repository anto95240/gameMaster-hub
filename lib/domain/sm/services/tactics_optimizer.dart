import 'dart:math'; // Ajout pour pow() (Moyenne géométrique)
import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class OptimizedStyles {
  final Map<String, double> general;
  final Map<String, double> attack;
  final Map<String, double> defense;
  OptimizedStyles(
      {required this.general, required this.attack, required this.defense});
}

class OptimizedTacticsResult {
  final String formation;
  final int? modeleId;
  final Map<int, int> joueurIdToRoleId;
  final OptimizedStyles styles;
  final Map<String, _JoueurStatsComplet> elevenByPoste;

  OptimizedTacticsResult({
    required this.formation,
    required this.modeleId,
    required this.joueurIdToRoleId,
    required this.styles,
    required this.elevenByPoste,
  });
}

class _JoueurStatsComplet {
  final JoueurSm joueur;
  final dynamic stats;
  final bool isGk;
  final double averageRating;
  final PosteEnum? preferredPoste;

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
        return 0.0;
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

  // ### AMÉLIORATION 1 : COMPATIBILITÉ DE POSTE PLUS STRICTE ###
  bool canPlayPoste(String basePoste) {
    // La carte est beaucoup plus restrictive pour éviter les aberrations
    const Map<String, List<String>> compatibilityMap = {
      'G': ['G'],
      'DC': ['DC', 'MDC'],
      'DG': ['DG', 'DLG'],
      'DD': ['DD', 'DLD'],
      'DLG': ['DLG', 'DG', 'MG'],
      'DLD': ['DLD', 'DD', 'MD'],
      'MDC': ['MDC', 'MC', 'DC'],
      'MC': ['MC', 'MDC', 'MOC'], // Ne peut plus jouer sur les ailes par défaut
      'MOC': ['MOC', 'MC', 'MOG', 'MOD', 'BUC'],
      'MG': ['MG', 'MOG', 'DLG'],
      'MD': ['MD', 'MOD', 'DLD'],
      'MOG': ['MOG', 'MG', 'MOC', 'BUG'],
      'MOD': ['MOD', 'MD', 'MOC', 'BUD'],
      'BUC': ['BUC', 'MOC', 'MOG', 'MOD'],
      'BUG': ['BUG', 'BUC', 'MOG'],
      'BUD': ['BUD', 'BUC', 'MOD'],
    };

    final List<String> compatibleEnumPostes =
        compatibilityMap[basePoste] ?? [basePoste];

    for (final playerPoste in joueur.postes) {
      if (compatibleEnumPostes.contains(playerPoste.name)) {
        return true;
      }
    }
    return false;
  }

  bool isPreferredPoste(String basePoste) {
    if (preferredPoste == null) return false;

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

    final List<String> compatibleEnumPostes =
        preferredMap[basePoste] ?? [basePoste];
    return compatibleEnumPostes.contains(preferredPoste!.name);
  }

  bool isCorrectLateral(String basePoste) {
    if (preferredPoste == null) return true;
    if (basePoste == 'DG')
      return preferredPoste!.name == 'DG' || preferredPoste!.name == 'DLG';
    if (basePoste == 'DD')
      return preferredPoste!.name == 'DD' || preferredPoste!.name == 'DLD';
    return true;
  }

  bool isCorrectWinger(String basePoste) {
    if (preferredPoste == null) return true;
    if (basePoste == 'MG' || basePoste == 'MOG')
      return preferredPoste!.name == 'MG' ||
          preferredPoste!.name == 'MOG' ||
          preferredPoste!.name == 'BUG';
    if (basePoste == 'MD' || basePoste == 'MOD')
      return preferredPoste!.name == 'MD' ||
          preferredPoste!.name == 'MOD' ||
          preferredPoste!.name == 'BUD';
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

  Future<OptimizedTacticsResult> optimize({required int saveId}) async {
    final allPlayers = await _getCombinedPlayerData(saveId);

    if (allPlayers.length < 11) {
      throw Exception("Vous devez avoir au moins 11 joueurs pour optimiser.");
    }

    final allFormationsPossibles = await tactiqueModeleRepo.getAllTactiques();
    final allRolesPossibles = await roleRepo.getAllRoles();

    final bestFormationResult = _findBestFormation(
        allFormationsPossibles, allPlayers, allRolesPossibles);

    final TactiqueModeleSm bestFormationModele = bestFormationResult['modele'];
    final List<_JoueurStatsComplet> startingEleven =
        bestFormationResult['eleven'];
    final Map<String, _JoueurStatsComplet> elevenByPoste =
        bestFormationResult['elevenByPoste'];

    final Map<int, int> joueurToRole = _assignBestRoles(
      elevenByPoste,
      allRolesPossibles,
    );

    final styles = _generateBestStyles(startingEleven);

    return OptimizedTacticsResult(
      formation: bestFormationModele.formation,
      modeleId: bestFormationModele.id,
      joueurIdToRoleId: joueurToRole,
      styles: styles,
      elevenByPoste: elevenByPoste,
    );
  }

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

      combinedList
          .add(_JoueurStatsComplet(joueur: j, stats: stats, isGk: isGk));
    }
    return combinedList;
  }

  Map<String, dynamic> _findBestFormation(
    List<TactiqueModeleSm> allFormations,
    List<_JoueurStatsComplet> allPlayers,
    List<RoleModeleSm> allRoles,
  ) {
    if (allFormations.isEmpty) {
      allFormations.add(TactiqueModeleSm(id: 0, formation: '4-3-3'));
    }

    double bestFinalScore = -double.maxFinite;
    TactiqueModeleSm bestModele = allFormations.first;
    List<_JoueurStatsComplet> bestEleven = [];
    Map<String, _JoueurStatsComplet> bestElevenByPoste = {};

    for (final modele in allFormations) {
      final postesKeys = _getPosteKeysForFormation(modele.formation);

      if (postesKeys.isEmpty) continue;

      List<_JoueurStatsComplet> playerPool = List.from(allPlayers);
      List<_JoueurStatsComplet> currentEleven = [];
      Map<String, _JoueurStatsComplet> currentElevenByPoste = {};
      double startersScore = 0.0;
      double depthScore = 0.0;
      bool formationFeasible = true;

      for (final posteKey in postesKeys) {
        final basePoste = posteKey.replaceAll(RegExp(r'[0-9]'), '');

        _JoueurStatsComplet? bestPlayerForPoste =
            _findBestPlayerForPoste(playerPool, basePoste, allRoles);

        if (bestPlayerForPoste != null) {
          playerPool.remove(bestPlayerForPoste);
          currentEleven.add(bestPlayerForPoste);
          currentElevenByPoste[posteKey] = bestPlayerForPoste;
          startersScore +=
              _calculatePlayerScore(bestPlayerForPoste, basePoste, allRoles);
        } else {
          formationFeasible = false;
          break;
        }
      }

      if (!formationFeasible) continue;

      for (final posteKey in postesKeys) {
        final basePoste = posteKey.replaceAll(RegExp(r'[0-9]'), '');

        _JoueurStatsComplet? bestBackup =
            _findBestPlayerForPoste(playerPool, basePoste, allRoles);

        if (bestBackup != null) {
          playerPool.remove(bestBackup);
          depthScore +=
              _calculatePlayerScore(bestBackup, basePoste, allRoles);
        } else {
          depthScore -= 150;
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

    if (bestEleven.isEmpty) {
      throw Exception(
          "Impossible de former une équipe de 11 joueurs valides avec l'effectif actuel. "
          "Assurez-vous d'avoir au moins un Gardien (G) et suffisamment de défenseurs/milieux/attaquants.");
    }

    return {
      'modele': bestModele,
      'eleven': bestEleven,
      'elevenByPoste': bestElevenByPoste,
    };
  }

  _JoueurStatsComplet? _findBestPlayerForPoste(
    List<_JoueurStatsComplet> pool,
    String basePoste,
    List<RoleModeleSm> allRoles,
  ) {
    if (pool.isEmpty) return null;

    _JoueurStatsComplet? bestPlayer;
    double bestScore = -double.maxFinite;

    for (final player in pool) {
      double score =
          _calculatePlayerScore(player, basePoste, allRoles);
      if (score > bestScore) {
        bestScore = score;
        bestPlayer = player;
      }
    }

    if (bestScore <= -1000) {
      return null;
    }

    return bestPlayer;
  }

  // ### AMÉLIORATION 2 : HARMONIE DES RÔLES (MOYENNE GÉOMÉTRIQUE) ###

  // Nouvelle fonction helper pour calculer le score de rôle (Moyenne Géométrique)
  double _calculateRoleScore(_JoueurStatsComplet player, List<String> keyStats) {
    if (keyStats.isEmpty) {
      return player.averageRating;
    }
    
    double score = 1.0;
    int statsCount = 0;
    
    for (final statName in keyStats) {
      double statVal = player.getStat(statName).toDouble();
      // On utilise 1.0 si la stat est 0 ou négative pour ne pas fausser la multiplication
      score *= (statVal <= 0 ? 1.0 : statVal); 
      statsCount++;
    }

    if (statsCount == 0) return player.averageRating;

    // pow(score, 1/N) -> Moyenne géométrique
    return pow(score, 1.0 / statsCount).toDouble();
  }


  double _calculatePlayerScore(
    _JoueurStatsComplet player,
    String basePoste,
    List<RoleModeleSm> allRoles,
  ) {
    if (basePoste == 'G') {
      return player.isGk ? player.averageRating * 1.5 : -1000;
    }
    if (player.isGk) {
      return -1000;
    }

    // Utilise la nouvelle méthode canPlayPoste (plus stricte)
    if (!player.canPlayPoste(basePoste)) {
      return -1000;
    }

    double baseScore = 0.0;
    final possibleRoles = allRoles.where((r) => r.poste == basePoste).toList();
    
    if (possibleRoles.isEmpty) {
      // Fallback : utiliser l'ancienne logique de poste
      final keyStats = _getKeyStatsForPoste(basePoste);
      baseScore = _calculateRoleScore(player, keyStats); // Utilise la nouvelle fonction
    } else {
      // Calculer le score pour chaque rôle et prendre le meilleur
      double bestRoleScore = -1.0;
      for (final role in possibleRoles) {
        final keyStats = _getKeyStatsForRole(role.role);
        // Utilise la nouvelle fonction de moyenne géométrique
        double currentRoleScore = _calculateRoleScore(player, keyStats);
        
        if (currentRoleScore > bestRoleScore) {
          bestRoleScore = currentRoleScore;
        }
      }
      baseScore = bestRoleScore;
    }
    
    // Pondération (statut, potentiel, etc.)
    if (!player.isCorrectLateral(basePoste) ||
        !player.isCorrectWinger(basePoste)) {
      baseScore *= 0.6;
    }

    if (player.isPreferredPoste(basePoste)) {
      baseScore *= 1.5;
    }

    switch (player.joueur.status) {
      case StatusEnum.Titulaire:
        baseScore *= 2.0;
        break;
      case StatusEnum.Remplacant:
        baseScore *= 0.8;
        break;
      case StatusEnum.Preter:
      case StatusEnum.Vendre:
        return -1000;
    }

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

  // Gardé comme fallback pour _calculatePlayerScore
  List<String> _getKeyStatsForPoste(String poste) {
    switch (poste) {
      case 'G':
        return [
          'arrets',
          'positionnement',
          'duels',
          'captation',
          'autorite_surface'
        ];
      case 'DC':
        return [
          'marquage',
          'tacles',
          'force',
          'positionnement',
          'stabilite_aerienne'
        ];
      case 'DG':
      case 'DD':
      case 'DLG':
      case 'DLD':
        return ['vitesse', 'endurance', 'centres', 'tacles', 'marquage'];
      case 'MDC':
        return [
          'tacles',
          'endurance',
          'agressivite',
          'passes',
          'positionnement'
        ];
      case 'MC':
        return ['passes', 'creativite', 'controle', 'endurance', 'deplacement'];
      case 'MOC':
        return [
          'creativite',
          'dribble',
          'frappes_lointaines',
          'passes',
          'deplacement'
        ];
      case 'MG':
      case 'MD':
      case 'MOG': 
      case 'MOD': 
        return ['vitesse', 'dribble', 'centres', 'creativite', 'finition'];
      case 'BUC':
      case 'BUG':
      case 'BUD':
        return [
          'finition',
          'deplacement',
          'sang_froid',
          'vitesse',
          'stabilite_aerienne'
        ];
      default:
        return ['vitesse', 'endurance', 'force'];
    }
  }

  Map<int, int> _assignBestRoles(
    Map<String, _JoueurStatsComplet> elevenByPoste,
    List<RoleModeleSm> allRoles,
  ) {
    final Map<int, int> joueurToRole = {};

    for (final entry in elevenByPoste.entries) {
      final String poste = entry.key.replaceAll(RegExp(r'[0-9]'), '');
      final _JoueurStatsComplet player = entry.value;

      final possibleRoles = allRoles.where((r) => r.poste == poste).toList();
      if (possibleRoles.isEmpty) continue;

      RoleModeleSm bestRole = possibleRoles.first;
      double bestScore = -1.0;

      for (final role in possibleRoles) {
        final keyStats = _getKeyStatsForRole(role.role);
        
        // Utilise la nouvelle fonction de moyenne géométrique
        double currentScore = _calculateRoleScore(player, keyStats);

        if (currentScore > bestScore) {
          bestScore = currentScore;
          bestRole = role;
        }
      }
      joueurToRole[player.joueur.id] = bestRole.id;
    }
    return joueurToRole;
  }

  // ### AMÉLIORATION 3 : HARMONIE DES STYLES (PRISE EN COMPTE DU MINIMUM) ###
  
  OptimizedStyles _generateBestStyles(List<_JoueurStatsComplet> eleven) {
    // La fonction _calculateTeamAverages retourne maintenant des moyennes ET des minimums
    final stats = _calculateTeamAverages(eleven);

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
      ..._getBestPressing(stats), // Logique améliorée
      ..._getBestStyleTacle(stats),
      ..._getBestLigneDefensive(stats), // Logique améliorée
      ..._getBestGardienLibero(stats),
      ..._getBestPerteTemps(stats),
    };

    return OptimizedStyles(general: general, attack: attack, defense: defense);
  }

  // AMÉLIORATION : Calcule des moyennes ET des minimums
  Map<String, double> _calculateTeamAverages(List<_JoueurStatsComplet> eleven) {
    Map<String, double> averages = {
      'avgVitesse_All': 0, 'avgEndurance_All': 0, 'avgAgressivite_All': 0, 'avgCreativite_All': 0,
      'avgPasses_All': 0, 'avgFinition_All': 0, 'avgTacles_All': 0, 'avgPositionnementDef_All': 0,
      'avgDeplacementOff_All': 0, 'avgPassesLongues_All': 0, 'avgCentres_All': 0,
      'avgControle_All': 0, 'avgDribble_All': 0, 'avgSangFroid_All': 0, 'avgFrappesLointaines_All': 0,
      'avgVitesse_Def': 0, 'avgPassesLongues_Def': 0,
      'avgVitesse_Mid': 0, 'avgPasses_Mid': 0,
      'avgVitesse_Att': 0, 'avgFinition_Att': 0,
      'gk_distribution': 0, 'gk_arrets': 0, 'gk_vitesse': 0,
      
      // Nouvelles stats MINIMALES
      'minEndurance_All': 100.0,
      'minVitesse_Def': 100.0,
    };
    
    int fieldPlayers = 0;
    int defCount = 0, midCount = 0, attCount = 0;

    for (final p in eleven) {
      if (p.isGk) {
        averages['gk_distribution'] = p.getStat('distribution').toDouble();
        averages['gk_arrets'] = p.getStat('arrets').toDouble();
        averages['gk_vitesse'] = p.getStat('vitesse').toDouble();
        continue;
      }
      
      fieldPlayers++;
      final poste = p.preferredPoste?.name ?? '';
      final stats = p.stats as StatsJoueurSmModel?;
      if (stats == null) continue;

      // --- Calcul des Stats Générales (Moyennes) ---
      averages['avgVitesse_All'] = (averages['avgVitesse_All'] ?? 0) + stats.vitesse;
      averages['avgEndurance_All'] = (averages['avgEndurance_All'] ?? 0) + stats.endurance;
      averages['avgAgressivite_All'] = (averages['avgAgressivite_All'] ?? 0) + stats.agressivite;
      averages['avgCreativite_All'] = (averages['avgCreativite_All'] ?? 0) + stats.creativite;
      averages['avgPasses_All'] = (averages['avgPasses_All'] ?? 0) + stats.passes;
      averages['avgFinition_All'] = (averages['avgFinition_All'] ?? 0) + stats.finition;
      averages['avgTacles_All'] = (averages['avgTacles_All'] ?? 0) + stats.tacles;
      averages['avgPositionnementDef_All'] = (averages['avgPositionnementDef_All'] ?? 0) + stats.positionnement;
      averages['avgDeplacementOff_All'] = (averages['avgDeplacementOff_All'] ?? 0) + stats.deplacement;
      averages['avgPassesLongues_All'] = (averages['avgPassesLongues_All'] ?? 0) + stats.passesLongues;
      averages['avgCentres_All'] = (averages['avgCentres_All'] ?? 0) + stats.centres;
      averages['avgControle_All'] = (averages['avgControle_All'] ?? 0) + stats.controle;
      averages['avgDribble_All'] = (averages['avgDribble_All'] ?? 0) + stats.dribble;
      averages['avgSangFroid_All'] = (averages['avgSangFroid_All'] ?? 0) + stats.sangFroid;
      averages['avgFrappesLointaines_All'] = (averages['avgFrappesLointaines_All'] ?? 0) + stats.frappesLointaines;

      // --- Calcul des Stats Minimales ---
      if (stats.endurance < averages['minEndurance_All']!) {
        averages['minEndurance_All'] = stats.endurance.toDouble();
      }

      // --- Calcul des Stats par Ligne ---
      if (poste.startsWith('D')) {
        defCount++;
        averages['avgVitesse_Def'] = (averages['avgVitesse_Def'] ?? 0) + stats.vitesse;
        averages['avgPassesLongues_Def'] = (averages['avgPassesLongues_Def'] ?? 0) + stats.passesLongues;
        if (stats.vitesse < averages['minVitesse_Def']!) {
          averages['minVitesse_Def'] = stats.vitesse.toDouble();
        }
      } else if (poste.startsWith('M')) {
        midCount++;
        averages['avgVitesse_Mid'] = (averages['avgVitesse_Mid'] ?? 0) + stats.vitesse;
        averages['avgPasses_Mid'] = (averages['avgPasses_Mid'] ?? 0) + stats.passes;
        averages['avgPassesLongues_Def'] = (averages['avgPassesLongues_Def'] ?? 0) + stats.passesLongues;
      } else if (poste.startsWith('B') || poste.contains('MOD') || poste.contains('MOG')) {
        attCount++;
        averages['avgVitesse_Att'] = (averages['avgVitesse_Att'] ?? 0) + stats.vitesse;
        averages['avgFinition_Att'] = (averages['avgFinition_Att'] ?? 0) + stats.finition;
      }
    }

    // --- Finalisation des calculs (Moyennes) ---
    if (fieldPlayers > 0) {
      averages.forEach((key, value) {
        // Ne diviser que les stats 'avg' et pas les 'min'
        if (key.startsWith('avg') && !key.contains('_Def') && !key.contains('_Mid') && !key.contains('_Att')) {
          averages[key] = value / fieldPlayers;
        }
      });
    }
    if (defCount > 0) {
      averages['avgVitesse_Def'] = averages['avgVitesse_Def']! / defCount;
    } else {
       averages['minVitesse_Def'] = averages['minEndurance_All']!; // Fallback si pas de def
    }
    if (defCount + midCount > 0) {
       averages['avgPassesLongues_Def'] = averages['avgPassesLongues_Def']! / (defCount + midCount);
    }
    if (midCount > 0) {
      averages['avgVitesse_Mid'] = averages['avgVitesse_Mid']! / midCount;
      averages['avgPasses_Mid'] = averages['avgPasses_Mid']! / midCount;
    }
    if (attCount > 0) {
      averages['avgVitesse_Att'] = averages['avgVitesse_Att']! / attCount;
      averages['avgFinition_Att'] = averages['avgFinition_Att']! / attCount;
    }
    
    // --- Fallbacks pour les stats par ligne (au cas où) ---
    if (averages['avgVitesse_Def'] == 0) averages['avgVitesse_Def'] = averages['avgVitesse_All'] ?? 50;
    if (averages['avgVitesse_Att'] == 0) averages['avgVitesse_Att'] = averages['avgVitesse_All'] ?? 50;
    if (averages['avgPassesLongues_Def'] == 0) averages['avgPassesLongues_Def'] = averages['avgPassesLongues_All'] ?? 50;

    return averages;
  }
  
  // (Resserrement des fourchettes "Normal" -> 50-60)
  
  Map<String, double> _getBestLargeur(Map<String, double> stats) {
    double avgCentres = stats['avgCentres_All'] ?? 50;
    if (avgCentres > 60) return {'Largeur: Jeu large': 1.0};
    if (avgCentres < 50) return {'Largeur: Étroit': 1.0};
    return {'Largeur: Normal': 1.0};
  }

  Map<String, double> _getBestMentalite(Map<String, double> stats) {
    double avgCreativite = stats['avgCreativite_All'] ?? 50;
    double avgFinition = stats['avgFinition_All'] ?? 50;
    double avgTacles = stats['avgTacles_All'] ?? 50;
    if (avgCreativite > 70 && avgFinition > 65) return {'Mentalité: Très offensive': 1.0};
    if (avgCreativite > 60 || avgFinition > 60) return {'Mentalité: Offensive': 1.0};
    if (avgTacles > 70 && avgCreativite < 45) return {'Mentalité: Très défensive': 1.0};
    if (avgTacles > 60 && avgCreativite < 50) return {'Mentalité: Défensive': 1.0};
    return {'Mentalité: Normal': 1.0};
  }

  Map<String, double> _getBestTempo(Map<String, double> stats) {
    double avgVitesse = stats['avgVitesse_All'] ?? 50;
    if (avgVitesse > 60) return {'Tempo: Rapide': 1.0};
    if (avgVitesse < 50) return {'Tempo: Lent': 1.0};
    return {'Tempo: Normal': 1.0};
  }
  
  Map<String, double> _getBestFluidite(Map<String, double> stats) {
    double avgDeplacement = stats['avgDeplacementOff_All'] ?? 50;
    if (avgDeplacement > 60) return {'Fluidité de la formation: Aventureux': 1.0};
    if (avgDeplacement < 50) return {'Fluidité de la formation: Discipliné': 1.0};
    return {'Fluidité de la formation: Normal': 1.0};
  }
  
  Map<String, double> _getBestRythmeTravail(Map<String, double> stats) {
    double avgEndurance = stats['avgEndurance_All'] ?? 50;
    if (avgEndurance > 60) return {'Rythme de travail: Rapide': 1.0};
    if (avgEndurance < 50) return {'Rythme de travail: Lent': 1.0};
    return {'Rythme de travail: Normal': 1.0};
  }

  Map<String, double> _getBestCreativite(Map<String, double> stats) {
    double avgCreativite = stats['avgCreativite_All'] ?? 50;
    if (avgCreativite > 60) return {'Créativité: Audacieux': 1.0};
    if (avgCreativite < 50) return {'Créativité: Prudent': 1.0};
    return {'Créativité: Équilibré': 1.0};
  }

  Map<String, double> _getBestStylePasse(Map<String, double> stats) {
    double avgPasses = stats['avgPasses_All'] ?? 50;
    double avgPassesLongues = stats['avgPassesLongues_All'] ?? 50;
    if (avgPassesLongues > 65 && avgPasses < 55) return {'Style de passe: Ballon longs': 1.0};
    if (avgPasses > 65 && avgPassesLongues < 55) return {'Style de passe: Court': 1.0};
    if (avgPasses > 60 && avgPassesLongues > 60) return {'Style de passe: Direct': 1.0};
    return {'Style de passe: Polyvalent': 1.0};
  }
  
  Map<String, double> _getBestStyleAttaque(Map<String, double> stats) {
    double avgDribble = stats['avgDribble_All'] ?? 50;
    double avgCentres = stats['avgCentres_All'] ?? 50;
    if(avgDribble > 60 && avgCentres > 60) return {'Style d\'attaque: Sur les deux ailes': 1.0};
    if(avgDribble > 60) return {'Style d\'attaque: Par l\'axe': 1.0};
    return {'Style d\'attaque: Polyvalent': 1.0};
  }

  Map<String, double> _getBestAttaquants(Map<String, double> stats) {
    double avgFinition = stats['avgFinition_Att'] ?? 50;
    double avgFrappesLointaines = stats['avgFrappesLointaines_All'] ?? 50;
    if (avgFinition > 60) return {'Attaquants: Jouer le ballon dans la surface': 1.0};
    if (avgFrappesLointaines > 60) return {'Attaquants: Tirer à vue': 1.0};
    return {'Attaquants: Polyvalents': 1.0};
  }
  
  Map<String, double> _getBestJeuLarge(Map<String, double> stats) {
    double avgCentres = stats['avgCentres_All'] ?? 50;
    if (avgCentres > 60) return {'Jeu large: Centres de la ligne de touche': 1.0};
    return {'Jeu large: Polyvalent': 1.0};
  }

  Map<String, double> _getBestJeuConstruction(Map<String, double> stats) {
    double avgControle = stats['avgControle_All'] ?? 50;
    if (avgControle > 60) return {'Jeu en contruction: Lent': 1.0}; 
    if (avgControle < 50) return {'Jeu en contruction: Rapide': 1.0};
    return {'Jeu en contruction: Normal': 1.0};
  }
  
  Map<String, double> _getBestContreAttaque(Map<String, double> stats) {
    double avgVitesseAtt = stats['avgVitesse_Att'] ?? 50;
    double avgPassesLonguesDef = stats['avgPassesLongues_Def'] ?? 50;
    if (avgVitesseAtt > 65 && avgPassesLonguesDef > 60) return {'Contre-attaque: Oui': 1.0};
    return {'Contre-attaque: Non': 1.0};
  }
  
  // AMÉLIORATION : Logique combinatoire ET vérification du MINIMUM
  Map<String, double> _getBestPressing(Map<String, double> stats) {
    double avgEndurance = stats['avgEndurance_All'] ?? 50;
    double minEndurance = stats['minEndurance_All'] ?? 50;
    double avgAgressivite = stats['avgAgressivite_All'] ?? 50;
    
    // Ne peut presser "partout" que si personne n'a une endurance trop faible
    if (avgEndurance > 65 && minEndurance > 50 && avgAgressivite > 60) {
      return {'Pressing: Partout': 1.0};
    }
    if (avgEndurance > 55) {
      return {'Pressing: Propre moitié de terrain': 1.0};
    }
    return {'Pressing: Propre surface de réparation': 1.0};
  }

  Map<String, double> _getBestStyleTacle(Map<String, double> stats) {
    double avgAgressivite = stats['avgAgressivite_All'] ?? 50;
    double avgTacles = stats['avgTacles_All'] ?? 50;
    if (avgAgressivite > 70 && avgTacles > 65) return {'Style tacle: Agressif': 1.0};
    if (avgAgressivite > 60) return {'Style tacle: Rugeux': 1.0};
    return {'Style tacle: Normal': 1.0};
  }

  // AMÉLIORATION : Utilise la vitesse des défenseurs ET vérification du MINIMUM
  Map<String, double> _getBestLigneDefensive(Map<String, double> stats) {
    double avgVitesseDef = stats['avgVitesse_Def'] ?? 50;
    double minVitesseDef = stats['minVitesse_Def'] ?? 50;
    
    // Ne peut jouer "Haut" que si aucun défenseur n'est trop lent
    if (avgVitesseDef > 60 && minVitesseDef > 55) {
      return {'Ligne défensive: Haut': 1.0};
    }
    // Si la moyenne est basse OU si un seul joueur est trop lent
    if (avgVitesseDef < 50 || minVitesseDef < 45) {
      return {'Ligne défensive: Bas': 1.0};
    }
    return {'Ligne défensive: Normal': 1.0};
  }
  
  Map<String, double> _getBestGardienLibero(Map<String, double> stats) {
    double avgGkVit = stats['gk_vitesse'] ?? 50;
    if (avgGkVit > 60) return {'Gardien libéro: Oui': 1.0};
    return {'Gardien libéro: Non': 1.0};
  }
  
  Map<String, double> _getBestPerteTemps(Map<String, double> stats) {
    double avgMentalite = (stats['avgCreativite_All'] ?? 50) + (stats['avgFinition_All'] ?? 50);
    if (avgMentalite > 120) return {'Perte de temps: Faible': 1.0}; // Mentalité offensive
    if (avgMentalite < 100) return {'Perte de temps: Haut': 1.0}; // Mentalité défensive
    return {'Perte de temps: Normal': 1.0};
  }

  List<String> _getPosteKeysForFormation(String formation) {
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
    return map[formation] ?? map['4-3-3']!; 
  }

  List<String> _getKeyStatsForRole(String roleName) {
    // (Mise à jour pour être plus précis et harmonieux)
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
        // Fallback générique
        return ['vitesse', 'endurance', 'force', 'passes', 'creativite', 'finition', 'tacles'];
    }
  }
}