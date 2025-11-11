import 'dart:math';
import 'package:gamemaster_hub/domain/domain_export.dart';
// ✅ AJOUT DES IMPORTS (que vous avez fournis)
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
  OptimizedTacticsResult({
    required this.formation,
    required this.modeleId,
    required this.joueurIdToRoleId,
    required this.styles,
  });
}

/// Classe interne pour fusionner les données joueur + stats
class _JoueurStatsComplet {
  final JoueurSm joueur;
  final dynamic stats;
  final bool isGk;
  final double averageRating;

  _JoueurStatsComplet(
      {required this.joueur, required this.stats, required this.isGk})
      : averageRating = _calculateAverageRating(stats);

  static double _calculateAverageRating(dynamic stats) {
    if (stats == null) return 0.0;
    try {
      final json = stats.toJson();
      final values = json.values
          .whereType<num>()
          .map((v) => v.toDouble())
          .where((v) => v > 0) // Ne pas compter les stats non renseignées
          .toList();
      if (values.isEmpty) return 0.0;
      return values.reduce((a, b) => a + b) / values.length;
    } catch (_) {
      return 0.0;
    }
  }

  /// Vérifie si un joueur peut jouer à un poste (ex: 'DC', 'MC', 'BU')
  bool canPlay(String poste) {
    return joueur.postes.any((p) => p.name == poste);
  }

  /// Retourne la stat spécifique (ex: 'passes', 'tacles')
  int getStat(String statName) {
    if (stats == null) return 0;
    try {
      final json = stats.toJson();
      if (json.containsKey(statName)) {
        return (json[statName] as num).toInt();
      }
    } catch (_) {
      // ignore
    }
    return 0;
  }
}

class TacticsOptimizer {
  final JoueurSmRepository joueurRepo;
  final StatsJoueurSmRepository statsRepo;
  final StatsGardienSmRepository gardienRepo;
  final RoleModeleSmRepository roleRepo;
  final TactiqueModeleSmRepository tactiqueModeleRepo;

  // ✅ CORRECTION : Renommage des variables (plus de 'Modele')
  final InstructionGeneralSmRepository instructionGeneralRepo;
  final InstructionAttaqueSmRepository instructionAttaqueRepo;
  final InstructionDefenseSmRepository instructionDefenseRepo;

  TacticsOptimizer({
    required this.joueurRepo,
    required this.statsRepo,
    required this.gardienRepo,
    required this.roleRepo,
    required this.tactiqueModeleRepo,
    // ✅ CORRECTION
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

    // ✅ CORRECTION (Erreurs 1-3) : Ajout de 'saveId'
    // Note: On n'utilise pas les styles modèles ici, on les génère.
    // Mais on les charge pour respecter le contrat (au cas où vous voudriez
    // les utiliser pour une logique plus avancée plus tard).
    await instructionGeneralRepo.getAllInstructions(saveId);
    await instructionAttaqueRepo.getAllInstructions(saveId);
    await instructionDefenseRepo.getAllInstructions(saveId);

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
      final isGk = j.postes.any((p) => p.name == 'GK');
      final stats = isGk ? gkStatsMap[j.id] : statsMap[j.id];
      combinedList.add(_JoueurStatsComplet(joueur: j, stats: stats, isGk: isGk));
    }
    return combinedList;
  }

  /// 🎯 ETAPE 1: Logique de sélection de la formation
  Map<String, dynamic> _findBestFormation(
    List<TactiqueModeleSm> allFormations,
    List<_JoueurStatsComplet> allPlayers,
  ) {
    if (allFormations.isEmpty) {
      allFormations.add(TactiqueModeleSm(id: 0, formation: '4-3-3'));
    }

    double bestScore = -1.0;
    TactiqueModeleSm bestModele = allFormations.first;
    List<_JoueurStatsComplet> bestEleven = [];
    Map<String, _JoueurStatsComplet> bestElevenByPoste = {};

    for (final modele in allFormations) {
      final postes = _getPostesForFormation(modele.formation);
      if (postes.isEmpty) continue; // Skip si formation inconnue

      List<_JoueurStatsComplet> playerPool = List.from(allPlayers);
      List<_JoueurStatsComplet> currentEleven = [];
      Map<String, _JoueurStatsComplet> currentElevenByPoste = {};
      double currentScore = 0.0;

      for (final poste in postes) {
        _JoueurStatsComplet? bestPlayerForPoste;
        // Trouve le meilleur joueur pour ce poste
        bestPlayerForPoste = playerPool.firstWhere(
          (p) => p.canPlay(poste),
          orElse: () => playerPool.firstWhere((p) => !p.isGk,
              orElse: () =>
                  _JoueurStatsComplet(joueur: JoueurSm.empty(), stats: null, isGk: false)),
        );

        if (bestPlayerForPoste.joueur.id != 0) {
          playerPool.remove(bestPlayerForPoste);
          currentEleven.add(bestPlayerForPoste);
          // ex: "DC1" -> joueurA, "DC2" -> joueurB
          String posteKey = poste;
          int i = 1;
          while (currentElevenByPoste.containsKey(posteKey)) {
            posteKey = "$poste$i";
            i++;
          }
          currentElevenByPoste[posteKey] = bestPlayerForPoste;
          currentScore += bestPlayerForPoste.averageRating;
        }
      }

      if (currentScore > bestScore) {
        bestScore = currentScore;
        bestModele = modele;
        bestEleven = currentEleven;
        bestElevenByPoste = currentElevenByPoste;
      }
    }

    return {
      'modele': bestModele,
      'eleven': bestEleven,
      'elevenByPoste': bestElevenByPoste,
    };
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
        // Logique de scoring basée sur les attributs clés (simplifiée)
        final keyStats = _getKeyStatsForRole(role.role);
        for (final statName in keyStats) {
          currentScore += player.getStat(statName);
        }

        if (currentScore > bestScore) {
          bestScore = currentScore;
          bestRole = role;
        }
      }
      joueurToRole[player.joueur.id] = bestRole.id;
    }
    return joueurToRole;
  }

  /// 🎯 ETAPE 4: Logique de génération des styles
  OptimizedStyles _generateBestStyles(List<_JoueurStatsComplet> eleven) {
    // Calcul des moyennes du 11 de départ
    double avgVitesse = 0,
        avgEndurance = 0,
        avgTacles = 0,
        avgPasses = 0,
        avgCreativite = 0,
        avgFinition = 0;
    
    for (final p in eleven) {
      avgVitesse += p.getStat('vitesse');
      avgEndurance += p.getStat('endurance');
      avgTacles += p.getStat('tacles');
      avgPasses += p.getStat('passes');
      avgCreativite += p.getStat('creativite');
      avgFinition += p.getStat('finition');
    }

    avgVitesse /= 11;
    avgEndurance /= 11;
    avgTacles /= 11;
    avgPasses /= 11;
    avgCreativite /= 11;
    avgFinition /= 11;

    // Génération des styles
    Map<String, double> general = {
      'Mentalité: ${avgCreativite > 12 ? "Positive" : "Équilibrée"}': (avgCreativite / 20 * 10).toPrecision(1),
      'Tempo: ${avgVitesse > 13 ? "Élevé" : "Normal"}': (avgVitesse / 20 * 10).toPrecision(1),
    };
    Map<String, double> attack = {
      'Style de passe: ${avgPasses > 13 ? "Court" : "Mixte"}': (avgPasses / 20 * 10).toPrecision(1),
      'Finition: ${avgFinition > 12.5 ? "Chercher le but" : "Patient"}': (avgFinition / 20 * 10).toPrecision(1),
    };
    Map<String, double> defense = {
      'Pressing: ${avgEndurance > 13 ? "Intense" : "Standard"}': (avgEndurance / 20 * 10).toPrecision(1),
      'Style tacle: ${avgTacles > 12 ? "Agressif" : "Mesuré"}': (avgTacles / 20 * 10).toPrecision(1),
    };

    return OptimizedStyles(general: general, attack: attack, defense: defense);
  }

  // --- MAPPINGS DE DONNÉES (Logique métier) ---

  /// Retourne les postes requis pour une formation. Ex: '4-3-3' -> ['GK', 'DG', ...]
  List<String> _getPostesForFormation(String formation) {
    // Vous devriez externaliser cela ou le charger depuis la DB
    final map = {
      '4-3-3': ['GK', 'DG', 'DC', 'DC', 'DD', 'MC', 'MC', 'MC', 'AG', 'AD', 'BU'],
      '4-4-2': ['GK', 'DG', 'DC', 'DC', 'DD', 'MG', 'MC', 'MC', 'MD', 'BU', 'BU'],
      '5-3-2': ['GK', 'DG', 'DC', 'DC', 'DC', 'DD', 'MC', 'MC', 'MC', 'BU', 'BU'],
      '3-5-2': ['GK', 'DC', 'DC', 'DC', 'MG', 'MC', 'MC', 'MC', 'MD', 'BU', 'BU'],
      '4-2-3-1': ['GK', 'DG', 'DC', 'DC', 'DD', 'MDC', 'MDC', 'MOC', 'AG', 'AD', 'BU'],
    };
    return map[formation] ?? [];
  }

  /// Définit quelles stats sont importantes pour quel rôle.
  List<String> _getKeyStatsForRole(String roleName) {
    // Logique simplifiée, à enrichir
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

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}