// lib/domain/sm/services/tactics_optimizer.dart
import 'dart:math';
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

const List<String> _allBasePostes = [
  'G', 'DC', 'DG', 'DD', 'DLG', 'DLD', 
  'MDC', 'MC', 'MOC', 'MG', 'MD', 'MOG', 'MOD', 
  'BUC', 'BUG', 'BUD'
];

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

  bool canPlayPoste(String basePoste) {
    const Map<String, List<String>> compatibilityMap = {
      'G': ['G'],
      'DC': ['DC'],
      'DG': ['DG', 'DLG'],
      'DD': ['DD', 'DLD'],
      'DLG': ['DLG', 'DG'],
      'DLD': ['DLD', 'DD'],
      'MDC': ['MDC'],
      'MC': ['MC', 'MDC', 'MOC'],
      'MOC': ['MOC', 'MC'],
      'MG': ['MG'],
      'MD': ['MD'],
      'MOG': ['MOG', 'MG'],
      'MOD': ['MOD', 'MD'],
      'BUC': ['BUC', 'BUG', 'BUD'],
      'BUG': ['BUG', 'BUC'],
      'BUD': ['BUD', 'BUC'],
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
    
    final Map<int, int> joueurToRole =
        bestFormationResult['joueurIdToRoleId'];

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
    Map<int, int> bestJoueurIdToRoleId = {};

    for (final modele in allFormations) {
      final postesKeys = _getPosteKeysForFormation(modele.formation);

      if (postesKeys.isEmpty) continue;

      List<_JoueurStatsComplet> playerPool = List.from(allPlayers);
      List<_JoueurStatsComplet> currentEleven = [];
      Map<String, _JoueurStatsComplet> currentElevenByPoste = {};
      Map<int, _PlayerScoreAndRole> bestRolesForStarters = {};
      double startersScore = 0.0;
      double depthScore = 0.0;
      bool formationFeasible = true;

      for (final posteKey in postesKeys) {
        final basePoste = posteKey.replaceAll(RegExp(r'[0-9]'), '');

        final bestSelection =
            _findBestPlayerForPoste(playerPool, basePoste, allRoles);

        if (bestSelection != null) {
          final bestPlayer = bestSelection.player;
          playerPool.remove(bestPlayer);
          currentEleven.add(bestPlayer);
          currentElevenByPoste[posteKey] = bestPlayer;
          startersScore += bestSelection.score;
          bestRolesForStarters[bestPlayer.joueur.id] = bestSelection;
        } else {
          formationFeasible = false;
          break;
        }
      }

      if (!formationFeasible) continue;

      final Map<int, int> currentJoueurIdToRoleId =
          _assignOptimalRoles(currentElevenByPoste, allRoles);

      for (final posteKey in postesKeys) {
        final basePoste = posteKey.replaceAll(RegExp(r'[0-9]'), '');

        final bestBackupSelection =
            _findBestPlayerForPoste(playerPool, basePoste, allRoles);

        if (bestBackupSelection != null) {
          playerPool.remove(bestBackupSelection.player);
          depthScore += bestBackupSelection.score;
        } else {
          depthScore -= 500;
        }
      }

      double totalFormationScore = startersScore + (depthScore * 0.5);

      if (totalFormationScore > bestFinalScore) {
        bestFinalScore = totalFormationScore;
        bestModele = modele;
        bestEleven = currentEleven;
        bestElevenByPoste = currentElevenByPoste;
        bestJoueurIdToRoleId = currentJoueurIdToRoleId;
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
      'joueurIdToRoleId': bestJoueurIdToRoleId,
    };
  }

  _PlayerScoreAndRole? _findBestPlayerForPoste(
    List<_JoueurStatsComplet> pool,
    String basePoste,
    List<RoleModeleSm> allRoles,
  ) {
    if (pool.isEmpty) return null;

    _JoueurStatsComplet? bestPlayer;
    double bestScore = -double.maxFinite;
    RoleModeleSm? bestRole;

    for (final player in pool) {
      final scoreAndRole =
          _calculatePlayerScore(player, basePoste, allRoles);
          
      if (scoreAndRole.score > bestScore) {
        bestScore = scoreAndRole.score;
        bestPlayer = player;
        bestRole = scoreAndRole.role;
      }
    }

    if (bestScore <= -1000 || bestPlayer == null) {
      return null;
    }

    return _PlayerScoreAndRole(player: bestPlayer!, score: bestScore, role: bestRole);
  }

  double _getGeoMean(_JoueurStatsComplet player, List<String> statNames) {
    if (statNames.isEmpty) {
      return 50.0;
    }
    double score = 1.0;
    int statsCount = 0;
    for (final statName in statNames) {
      double statVal = player.getStat(statName).toDouble();
      score *= (statVal <= 0 ? 1.0 : statVal);
      statsCount++;
    }
    if (statsCount == 0) return 50.0;
    return pow(score, 1.0 / statsCount).toDouble();
  }
  
  double _calculateRoleScore(_JoueurStatsComplet player, Map<String, List<String>> keyStats) {
    final primaryStats = keyStats['primary'] ?? [];
    final secondaryStats = keyStats['secondary'] ?? [];
    final tertiaryStats = keyStats['tertiary'] ?? [];

    if (primaryStats.isEmpty && secondaryStats.isEmpty && tertiaryStats.isEmpty) {
      return player.averageRating;
    }

    final primaryScore = _getGeoMean(player, primaryStats);
    final secondaryScore = _getGeoMean(player, secondaryStats);
    final tertiaryScore = _getGeoMean(player, tertiaryStats);

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

    if (totalWeight == 0) return player.averageRating;
    return totalScore / totalWeight;
  }

  _PlayerScoreAndRole _calculateBestRoleScoreForPoste(
    _JoueurStatsComplet player,
    String basePoste,
    List<RoleModeleSm> allRoles,
  ) {
    if (basePoste == 'G' && !player.isGk) return _PlayerScoreAndRole(player: player, score: 0.0, role: null);
    if (player.isGk && basePoste != 'G') return _PlayerScoreAndRole(player: player, score: 0.0, role: null);

    final possibleRoles = allRoles.where((r) => r.poste == basePoste).toList();
    
    if (possibleRoles.isEmpty) {
      final keyStatsList = _getKeyStatsForPoste(basePoste);
      final List<String> allStats = [
        ...keyStatsList['primary'] ?? [], 
        ...keyStatsList['secondary'] ?? [],
        ...keyStatsList['tertiary'] ?? []
      ];
      return _PlayerScoreAndRole(player: player, score: _getGeoMean(player, allStats), role: null);
    }

    double bestRoleScore = -1.0;
    RoleModeleSm? bestRole;

    for (final role in possibleRoles) {
      final keyStats = _getKeyStatsForRole(role.role);
      double currentRoleScore = _calculateRoleScore(player, keyStats);
      
      if (currentRoleScore > bestRoleScore) {
        bestRoleScore = currentRoleScore;
        bestRole = role;
      }
    }
    return _PlayerScoreAndRole(player: player, score: bestRoleScore, role: bestRole);
  }

  _PlayerScoreAndRole _calculatePlayerScore(
    _JoueurStatsComplet player,
    String basePoste,
    List<RoleModeleSm> allRoles,
  ) {
    if (basePoste == 'G') {
      final score = player.isGk ? player.averageRating * 1.5 : -1000.0;
      return _PlayerScoreAndRole(player: player, score: score, role: null);
    }
    if (player.isGk) {
      return _PlayerScoreAndRole(player: player, score: -1000.0, role: null);
    }

    if (!player.canPlayPoste(basePoste)) {
      return _PlayerScoreAndRole(player: player, score: -1000.0, role: null);
    }

    final primaryRoleScore = _calculateBestRoleScoreForPoste(player, basePoste, allRoles);
    if (primaryRoleScore.score <= 0) return _PlayerScoreAndRole(player: player, score: -1000.0, role: null);

    final double roleScore = primaryRoleScore.score;
    final double overallNote = player.joueur.niveauActuel.toDouble();
    
    double baseScore = (roleScore * 0.6) + (overallNote * 0.4);

    double nextBestScore = 0.0;
    for (final otherPoste in _allBasePostes) {
      if (otherPoste == basePoste) continue;
      if (!player.canPlayPoste(otherPoste)) continue;
      
      double otherScore = _calculateBestRoleScoreForPoste(player, otherPoste, allRoles).score;
      if (otherScore > nextBestScore) {
        nextBestScore = otherScore;
      }
    }

    double specialistBonus = (roleScore - nextBestScore) * 0.5;
    baseScore += max(0, specialistBonus);
    
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
        return _PlayerScoreAndRole(player: player, score: -1000.0, role: null);
    }
    
    final age = player.joueur.age;
    if (age >= 24 && age <= 29) {
      baseScore *= 1.1;
    }

    double potentiel = player.joueur.potentiel.toDouble();
    if (potentiel < overallNote) potentiel = overallNote;

    double potentielMargin = potentiel - overallNote;
    if (potentielMargin > 0) {
      double potentialBonus = 1 + (potentielMargin / 200);
      
      if (age < 22) {
        potentialBonus *= 1.2;
      }
      
      baseScore *= potentialBonus;
    }

    return _PlayerScoreAndRole(player: player, score: baseScore, role: primaryRoleScore.role);
  }

  Map<String, List<String>> _getKeyStatsForPoste(String poste) {
    switch (poste) {
      case 'G':
        return {'primary': ['arrets', 'positionnement', 'duels'], 'secondary': ['captation', 'autorite_surface'], 'tertiary': []};
      case 'DC':
        return {'primary': ['marquage', 'tacles', 'force'], 'secondary': ['positionnement', 'stabilite_aerienne'], 'tertiary': ['agressivite']};
      case 'DG':
      case 'DD':
      case 'DLG':
      case 'DLD':
        return {'primary': ['vitesse', 'tacles', 'marquage'], 'secondary': ['endurance', 'centres'], 'tertiary': ['positionnement']};
      case 'MDC':
        return {'primary': ['tacles', 'agressivite', 'positionnement'], 'secondary': ['endurance', 'passes', 'force'], 'tertiary': ['marquage']};
      case 'MC':
        return {'primary': ['passes', 'creativite', 'controle'], 'secondary': ['endurance', 'deplacement'], 'tertiary': ['tacles', 'frappes_lointaines']};
      case 'MOC':
        return {'primary': ['creativite', 'dribble', 'passes'], 'secondary': ['frappes_lointaines', 'deplacement'], 'tertiary': ['finition', 'sang_froid']};
      case 'MG':
      case 'MD':
        return {'primary': ['vitesse', 'dribble', 'centres', 'endurance'], 'secondary': ['creativite', 'passes'], 'tertiary': ['tacles', 'marquage']};
      case 'MOG': 
      case 'MOD': 
        return {'primary': ['vitesse', 'dribble', 'centres'], 'secondary': ['creativite', 'finition', 'deplacement'], 'tertiary': ['passes']};
      case 'BUC':
      case 'BUG':
      case 'BUD':
        return {'primary': ['finition', 'deplacement', 'sang_froid'], 'secondary': ['vitesse', 'stabilite_aerienne'], 'tertiary': ['force', 'controle']};
      default:
        return {'primary': ['vitesse', 'endurance', 'force'], 'secondary': [], 'tertiary': []};
    }
  }

  Set<List<T>> _generateRolePermutations<T>(List<T> items, int length) {
    if (length == 0) {
      return {[]};
    }
    if (length > items.length) {
      length = items.length;
    }

    final allPerms = <List<T>>{};

    for (int i = 0; i < items.length; i++) {
      final currentItem = items[i];
      
      final remainingItems = List<T>.from(items)..removeAt(i);
      
      final permsOfRest = _generateRolePermutations(remainingItems, length - 1);

      for (final perm in permsOfRest) {
        allPerms.add([currentItem, ...perm]);
      }
    }
    
    return allPerms.map((list) => List<T>.from(list)).toSet();
  }

  Map<int, int> _assignOptimalRoles(
    Map<String, _JoueurStatsComplet> elevenByPoste,
    List<RoleModeleSm> allRoles,
  ) {
    final Map<int, int> joueurToRoleId = {};
    final Map<String, List<_JoueurStatsComplet>> groupedPlayers = {};

    for (final entry in elevenByPoste.entries) {
      final String basePoste = entry.key.replaceAll(RegExp(r'[0-9]'), '');
      final _JoueurStatsComplet player = entry.value;

      if (!groupedPlayers.containsKey(basePoste)) {
        groupedPlayers[basePoste] = [];
      }
      groupedPlayers[basePoste]!.add(player);
    }

    for (final entry in groupedPlayers.entries) {
      final String basePoste = entry.key;
      final List<_JoueurStatsComplet> playersInGroup = entry.value;
      final List<RoleModeleSm> rolesForPoste = allRoles.where((r) => r.poste == basePoste).toList();

      if (rolesForPoste.isEmpty) {
        for (final player in playersInGroup) {
          final bestRoleScore = _calculateBestRoleScoreForPoste(player, basePoste, allRoles);
          if (bestRoleScore.role != null) {
            joueurToRoleId[player.joueur.id] = bestRoleScore.role!.id;
          }
        }
        continue;
      }

      if (playersInGroup.length == 1) {
          final player = playersInGroup.first;
          final bestRoleScore = _calculateBestRoleScoreForPoste(player, basePoste, allRoles);
          if (bestRoleScore.role != null) {
            joueurToRoleId[player.joueur.id] = bestRoleScore.role!.id;
          }
          continue;
      }

      final List<RoleModeleSm> rolesToAssign = rolesForPoste.length >= playersInGroup.length
        ? rolesForPoste
        : List.generate(playersInGroup.length, (index) => rolesForPoste[index % rolesForPoste.length]);

      final rolePermutations = _generateRolePermutations(rolesToAssign, playersInGroup.length).toSet();
      
      double bestCombinationScore = -double.maxFinite;
      List<RoleModeleSm> bestRoleCombination = [];

      for (final perm in rolePermutations) {
        double currentCombinationScore = 0;
        final playersPermutation = _generateRolePermutations(playersInGroup, playersInGroup.length).toSet();
        
        double bestPlayerPermScore = -double.maxFinite;

        for (final playerPerm in playersPermutation) {
          double currentPlayerPermScore = 0;
          for (int i = 0; i < playerPerm.length; i++) {
            final player = playerPerm[i];
            final role = perm[i];
            final keyStats = _getKeyStatsForRole(role.role);
            currentPlayerPermScore += _calculateRoleScore(player, keyStats);
          }
          if (currentPlayerPermScore > bestPlayerPermScore) {
            bestPlayerPermScore = currentPlayerPermScore;
          }
        }
        currentCombinationScore = bestPlayerPermScore;

        if (currentCombinationScore > bestCombinationScore) {
          bestCombinationScore = currentCombinationScore;
          bestRoleCombination = perm.toList();
        }
      }

      if (bestRoleCombination.isNotEmpty) {
        
        final playersPermutation = _generateRolePermutations(playersInGroup, playersInGroup.length).toSet();
        List<_JoueurStatsComplet> bestPlayerPerm = playersInGroup;
        double bestPlayerPermScore = -double.maxFinite;

         for (final playerPerm in playersPermutation) {
          double currentPlayerPermScore = 0;
          for (int i = 0; i < playerPerm.length; i++) {
            final player = playerPerm[i];
            final role = bestRoleCombination[i];
            final keyStats = _getKeyStatsForRole(role.role);
            currentPlayerPermScore += _calculateRoleScore(player, keyStats);
          }
          if (currentPlayerPermScore > bestPlayerPermScore) {
            bestPlayerPermScore = currentPlayerPermScore;
            bestPlayerPerm = playerPerm.toList();
          }
        }

        for (int i = 0; i < bestPlayerPerm.length; i++) {
          joueurToRoleId[bestPlayerPerm[i].joueur.id] = bestRoleCombination[i].id;
        }
      }
    }
    
    return joueurToRoleId;
  }
  
  OptimizedStyles _generateBestStyles(List<_JoueurStatsComplet> eleven) {
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
      ..._getBestPressing(stats),
      ..._getBestStyleTacle(stats),
      ..._getBestLigneDefensive(stats),
      ..._getBestGardienLibero(stats),
      ..._getBestPerteTemps(stats),
    };

    return OptimizedStyles(general: general, attack: attack, defense: defense);
  }

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

      if (stats.endurance < averages['minEndurance_All']!) {
        averages['minEndurance_All'] = stats.endurance.toDouble();
      }

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

    if (fieldPlayers > 0) {
      averages.forEach((key, value) {
        if (key.startsWith('avg') && !key.contains('_Def') && !key.contains('_Mid') && !key.contains('_Att')) {
          averages[key] = value / fieldPlayers;
        }
      });
    }
    if (defCount > 0) {
      averages['avgVitesse_Def'] = averages['avgVitesse_Def']! / defCount;
    } else {
       averages['minVitesse_Def'] = averages['minEndurance_All']!;
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
    
    if (averages['avgVitesse_Def'] == 0) averages['avgVitesse_Def'] = averages['avgVitesse_All'] ?? 50;
    if (averages['avgVitesse_Att'] == 0) averages['avgVitesse_Att'] = averages['avgVitesse_All'] ?? 50;
    if (averages['avgPassesLongues_Def'] == 0) averages['avgPassesLongues_Def'] = averages['avgPassesLongues_All'] ?? 50;

    return averages;
  }
  
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
  
  Map<String, double> _getBestPressing(Map<String, double> stats) {
    double avgEndurance = stats['avgEndurance_All'] ?? 50;
    double minEndurance = stats['minEndurance_All'] ?? 50;
    double avgAgressivite = stats['avgAgressivite_All'] ?? 50;
    
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

  Map<String, double> _getBestLigneDefensive(Map<String, double> stats) {
    double avgVitesseDef = stats['avgVitesse_Def'] ?? 50;
    double minVitesseDef = stats['minVitesse_Def'] ?? 50;
    
    if (avgVitesseDef > 60 && minVitesseDef > 55) {
      return {'Ligne défensive: Haut': 1.0};
    }
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
    if (avgMentalite > 120) return {'Perte de temps: Faible': 1.0};
    if (avgMentalite < 100) return {'Perte de temps: Haut': 1.0};
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

  Map<String, List<String>> _getKeyStatsForRole(String roleName) {
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

class _PlayerScoreAndRole {
  final _JoueurStatsComplet player;
  final double score;
  final RoleModeleSm? role;

  _PlayerScoreAndRole({
    required this.player,
    required this.score,
    required this.role,
  });
}