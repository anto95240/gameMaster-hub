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

class TeamAnalyzer {
  final int saveId;
  final JoueursSmLoaded joueursState;
  final TacticsSmState tacticsState;
  final StatsJoueurSmRepositoryImpl joueurRepo;
  final StatsGardienSmRepositoryImpl gardienRepo;
  final RoleModeleSmRepositoryImpl roleRepo;

  final List<JoueurSmWithStats> _allPlayers;
  final List<JoueurSmWithStats> _starters = [];
  final Map<String, JoueurSmWithStats> _startersByPoste = {};
  final List<JoueurSmWithStats> _substitutes = [];
  List<RoleModeleSm> _allRoles = [];

  final List<String> forces = [];
  final List<String> faiblesses = [];
  final List<String> manques = [];
  
  // Nouveaux champs pour le profil d'équipe
  double _avgTechnique = 0;
  double _avgPhysique = 0;
  double _avgMental = 0;

  TeamAnalyzer({
    required this.saveId,
    required this.joueursState,
    required this.tacticsState,
    required this.joueurRepo,
    required this.gardienRepo,
    required this.roleRepo,
  }) : _allPlayers = joueursState.joueurs {
    final starterIds = tacticsState.assignedPlayersByPoste.values
        .where((p) => p != null)
        .map((p) => p!.joueur.id)
        .toSet();
    
    for (final p in _allPlayers) {
      if (starterIds.contains(p.joueur.id)) {
        _starters.add(p);
      } else {
        _substitutes.add(p);
      }
    }
    
    tacticsState.assignedPlayersByPoste.forEach((posteKey, player) {
      if (player != null) {
        _startersByPoste[posteKey] = player;
      }
    });
  }

  Future<AnalyseResult> analyser() async {
    if (_allPlayers.isEmpty) {
      return AnalyseResult(forces: [], faiblesses: [], manques: ["Aucun joueur dans l'effectif."]);
    }
    
    _allRoles = await roleRepo.getAllRoles();

    // 1. Analyse de l'effectif (général)
    _analyzeAgeStructure();
    _analyzeFinancialsAndValue(); // Renommée et améliorée
    _analyzeSquadDepth();
    _analyzeContractSituations();
    _analyzePotentialAndDevelopment(); // NOUVEAU
    _analyzeTeamProfile(); // NOUVEAU

    // 2. Analyse Tactique (si une tactique est chargée)
    if (tacticsState.status == TacticsStatus.loaded && _starters.isNotEmpty) {
      forces.add("Analyse basée sur la formation : ${tacticsState.selectedFormation}");
      _analyzeTacticalFit(); // Améliorée pour utiliser le profil
      _analyzeStartersVsBench();
      _analyzeRoleFit();
      _analyzeKeyPlayerDependency(); // NOUVEAU
    } else {
      manques.add("Aucune tactique optimisée. L'analyse tactique est indisponible.");
    }

    return AnalyseResult(
      forces: forces.toSet().toList(),
      faiblesses: faiblesses.toSet().toList(),
      manques: manques.toSet().toList(),
    );
  }

  void _analyzeAgeStructure() {
    // ... (Logique inchangée de la version précédente) ...
    if (_allPlayers.isEmpty) return;

    double totalAge = 0;
    double defAge = 0, midAge = 0, attAge = 0;
    int defCount = 0, midCount = 0, attCount = 0;
    int nbTalents = 0, nbEclosion = 0, nbPrime = 0, nbVeterans = 0;

    for (final j in _allPlayers) {
      final joueur = j.joueur;
      final age = joueur.age;
      totalAge += age;

      if (age < 20) nbTalents++;
      else if (age >= 20 && age <= 23) nbEclosion++;
      else if (age >= 24 && age <= 29) nbPrime++;
      else if (age >= 30) nbVeterans++;

      final poste = joueur.postes.isNotEmpty ? joueur.postes.first.name : '';
      if (poste.startsWith('D')) {
        defAge += age;
        defCount++;
      } else if (poste.startsWith('M')) {
        midAge += age;
        midCount++;
      } else if (poste.startsWith('B')) {
        attAge += age;
        attCount++;
      }
    }

    final avgAge = totalAge / _allPlayers.length;
    forces.add("Âge moyen de l'effectif : ${avgAge.toStringAsFixed(1)} ans.");
    if (defCount > 0) forces.add("Âge moyen défense : ${(defAge / defCount).toStringAsFixed(1)} ans.");
    if (midCount > 0) forces.add("Âge moyen milieu : ${(midAge / midCount).toStringAsFixed(1)} ans.");
    if (attCount > 0) forces.add("Âge moyen attaque : ${(attAge / attCount).toStringAsFixed(1)} ans.");

    if (avgAge < 23) faiblesses.add("Effectif très jeune, manque d'expérience global.");
    if (avgAge > 29) faiblesses.add("Effectif vieillissant, risque sur l'endurance et besoin de renouvellement.");
    
    if (nbTalents > 5) forces.add("Excellent vivier de jeunes talents (< 20 ans).");
    else if (nbTalents < 2) manques.add("Manque de jeunes talents (< 20 ans) pour préparer le futur.");
    
    if (nbPrime > 8) forces.add("Bon noyau de joueurs au sommet de leur carrière (24-29 ans).");
    else if (nbPrime < 4) manques.add("Peu de joueurs dans leur 'prime' (24-29 ans).");
    
    if (nbVeterans > 5) faiblesses.add("Nombre élevé de vétérans (>= 30 ans), risque de déclin.");
    else if (nbVeterans < 2) manques.add("Manque de vétérans (>= 30 ans) pour encadrer l'équipe.");
  }

  void _analyzeFinancialsAndValue() {
    double totalSalaire = 0;
    double totalValeur = 0;
    List<MapEntry<double, String>> playerValueIndex = [];
    
    for (final j in _allPlayers) {
      totalSalaire += j.joueur.salaire;
      totalValeur += j.joueur.montantTransfert;
      
      // Calcul de la rentabilité (Niveau / Salaire)
      // On ajoute 1 au salaire pour éviter la division par zéro si un joueur n'a pas de salaire (centre de formation)
      double index = (j.joueur.niveauActuel * 1000) / (j.joueur.salaire + 1);
      playerValueIndex.add(MapEntry(index, j.joueur.nom));
    }
    
    forces.add("Valeur marchande totale : ${totalValeur.toStringAsFixed(0)} €.");
    forces.add("Masse salariale annuelle : ${totalSalaire.toStringAsFixed(0)} €.");

    playerValueIndex.sort((a, b) => a.key.compareTo(b.key));
    
    final bestValue = playerValueIndex.reversed.take(3).map((e) => e.value).join(', ');
    final worstValue = playerValueIndex.take(3).map((e) => e.value).join(', ');

    forces.add("Meilleur rapport qualité/prix : $bestValue.");
    faiblesses.add("Pire rapport qualité/prix (à surveiller) : $worstValue.");
  }

  void _analyzeSquadDepth() {
    // ... (Logique inchangée de la version précédente) ...
    final postesCles = {'G': 0, 'DC': 0, 'DL': 0, 'MDC': 0, 'MC': 0, 'MOC': 0, 'AIL': 0, 'BU': 0};
    
    for (final j in _allPlayers) {
      for (final poste in j.joueur.postes) {
        if (poste.name == 'G') postesCles['G'] = (postesCles['G'] ?? 0) + 1;
        if (poste.name == 'DC') postesCles['DC'] = (postesCles['DC'] ?? 0) + 1;
        if (poste.name == 'DG' || poste.name == 'DD' || poste.name == 'DLG' || poste.name == 'DLD') postesCles['DL'] = (postesCles['DL'] ?? 0) + 1;
        if (poste.name == 'MDC') postesCles['MDC'] = (postesCles['MDC'] ?? 0) + 1;
        if (poste.name == 'MC') postesCles['MC'] = (postesCles['MC'] ?? 0) + 1;
        if (poste.name == 'MOC') postesCles['MOC'] = (postesCles['MOC'] ?? 0) + 1;
        if (poste.name == 'MG' || poste.name == 'MD' || poste.name == 'MOG' || poste.name == 'MOD') postesCles['AIL'] = (postesCles['AIL'] ?? 0) + 1;
        if (poste.name.startsWith('BU')) postesCles['BU'] = (postesCles['BU'] ?? 0) + 1;
      }
    }

    if (postesCles['G'] == 0) manques.add("Aucun gardien (G) dans l'effectif.");
    else if (postesCles['G'] == 1) manques.add("Un seul gardien (G), risque en cas de blessure.");
    
    if (postesCles['DC']! < 3) manques.add("Manque de profondeur au poste de Défenseur Central (DC).");
    if (postesCles['DL']! < 3) manques.add("Manque de profondeur aux postes de Latéraux (DG/DD).");
    if (postesCles['MC']! < 3) manques.add("Manque de profondeur au poste de Milieu Central (MC).");
    if (postesCles['BU']! < 2) manques.add("Manque de profondeur au poste de Buteur (BU).");
  }
  
  void _analyzeContractSituations() {
    // ... (Logique inchangée de la version précédente) ...
    final currentYear = 2025; 
    
    final contratsCourts = _allPlayers.where((p) => p.joueur.dureeContrat <= currentYear && p.joueur.niveauActuel > 70).toList();
    if (contratsCourts.isNotEmpty) {
      faiblesses.add("Joueurs clés en fin de contrat cette année (${currentYear}) : ${contratsCourts.map((p) => p.joueur.nom).join(', ')}.");
    }
  }

  // NOUVELLE MÉTHODE
  void _analyzePotentialAndDevelopment() {
    double totalPotential = 0;
    int highPotentialTalents = 0;
    int reachedPotential = 0;

    for (final p in _allPlayers) {
      final j = p.joueur;
      totalPotential += j.potentiel;
      
      if (j.age < 21 && j.potentiel > 85) {
        highPotentialTalents++;
      }
      if (j.niveauActuel >= j.potentiel) {
        reachedPotential++;
      }
    }
    
    final avgPotential = totalPotential / _allPlayers.length;
    final avgCurrent = _allPlayers.map((p) => p.joueur.niveauActuel).reduce((a, b) => a + b) / _allPlayers.length;
    final margin = avgPotential - avgCurrent;

    forces.add("Potentiel moyen de l'effectif : ${avgPotential.toStringAsFixed(1)} (Marge de progression : +${margin.toStringAsFixed(1)} points).");
    
    if (highPotentialTalents > 0) {
      forces.add("Possède $highPotentialTalents pépites (futurs cracks < 21 ans, pot > 85).");
    } else {
      manques.add("Manque de jeunes à très haut potentiel (> 85) pour assurer l'avenir.");
    }
    
    if (reachedPotential > _allPlayers.length / 2) {
      faiblesses.add("Plus de la moitié de l'effectif a atteint son potentiel maximum, peu de progression interne attendue.");
    }
  }

  // NOUVELLE MÉTHODE
  void _analyzeTeamProfile() {
    double totalTechnique = 0, totalPhysique = 0, totalMental = 0;
    int fieldPlayersCount = 0;

    for (final p in _allPlayers) {
      if (p.joueur.postes.first.name == 'G' || p.stats == null) continue;
      final stats = p.stats as StatsJoueurSm;
      fieldPlayersCount++;
      
      totalTechnique += (stats.passes + stats.controle + stats.dribble + stats.centres) / 4;
      totalPhysique += (stats.vitesse + stats.endurance + stats.force + stats.stabiliteAerienne) / 4;
      totalMental += (stats.creativite + stats.deplacement + stats.sangFroid + stats.positionnement) / 4;
    }
    
    if (fieldPlayersCount > 0) {
      _avgTechnique = totalTechnique / fieldPlayersCount;
      _avgPhysique = totalPhysique / fieldPlayersCount;
      _avgMental = totalMental / fieldPlayersCount;

      forces.add("Profil d'équipe : Technique (${_avgTechnique.toStringAsFixed(0)}), Physique (${_avgPhysique.toStringAsFixed(0)}), Mental (${_avgMental.toStringAsFixed(0)}).");
    }
  }

  void _analyzeStartersVsBench() {
    // ... (Logique inchangée de la version précédente) ...
    if (_starters.isEmpty) return;

    double avgStarterRating = _starters.map((p) => p.joueur.niveauActuel).reduce((a, b) => a + b) / _starters.length;
    forces.add("Note moyenne du 11 titulaire : ${avgStarterRating.toStringAsFixed(1)}.");
    
    if (_substitutes.isNotEmpty) {
      double avgSubRating = _substitutes.map((p) => p.joueur.niveauActuel).reduce((a, b) => a + b) / _substitutes.length;
      forces.add("Note moyenne des remplaçants : ${avgSubRating.toStringAsFixed(1)}.");

      if (avgStarterRating - avgSubRating > 15) {
        faiblesses.add("Gros écart de niveau entre les titulaires et le banc (${(avgStarterRating - avgSubRating).toStringAsFixed(1)} points).");
      } else if (avgStarterRating - avgSubRating < 5) {
        forces.add("Banc très compétitif, peu d'écart avec les titulaires.");
      }
    } else {
      manques.add("Aucun remplaçant disponible dans l'effectif.");
    }
  }

  void _analyzeTacticalFit() {
    final stylesAtt = tacticsState.stylesAttack;
    final stylesDef = tacticsState.stylesDefense;
    
    // La logique précédente sur l'endurance/vitesse est bonne, mais on la couple avec le profil
    
    if (stylesDef.keys.any((k) => k.contains('Pressing: Partout'))) {
      if (_avgPhysique < 65) {
        faiblesses.add("Style tactique : Le 'Pressing Partout' est très risqué avec un profil Physique moyen de (${_avgPhysique.toStringAsFixed(0)}).");
      } else {
        forces.add("Style tactique : Le profil Physique (${_avgPhysique.toStringAsFixed(0)}) est adapté au 'Pressing Partout'.");
      }
    }
    
    if (stylesAtt.keys.any((k) => k.contains('Style de passe: Court'))) {
      if (_avgTechnique < 65) {
        faiblesses.add("Style tactique : Le style 'Passe Courte' est peu adapté au profil Technique de l'équipe (${_avgTechnique.toStringAsFixed(0)}).");
      } else {
        forces.add("Style tactique : Le profil Technique (${_avgTechnique.toStringAsFixed(0)}) est idéal pour le style 'Passe Courte'.");
      }
    }
    
    if (stylesAtt.keys.any((k) => k.contains('Style de passe: Ballon longs'))) {
      if (_avgTechnique < 65) { // On suppose que 'passes longues' fait partie de la technique
        faiblesses.add("Style tactique : Le style 'Ballons Longs' est peu adapté (Profil Technique : ${_avgTechnique.toStringAsFixed(0)}).");
      }
    }

    if (stylesAtt.keys.any((k) => k.contains('Contre-attaque: Oui'))) {
      double avgVitesseAtt = 0;
      int attCount = 0;
      for (final p in _starters) {
         if (p.joueur.postes.first.name.startsWith('M') || p.joueur.postes.first.name.startsWith('B')) {
           if (p.stats != null) {
             avgVitesseAtt += (p.stats as StatsJoueurSm).vitesse;
             attCount++;
           }
         }
      }
      if (attCount > 0) avgVitesseAtt /= attCount;
      
      if (avgVitesseAtt < 70) {
        faiblesses.add("Style tactique : La 'Contre-attaque' manque de vitesse offensive (moyenne : ${avgVitesseAtt.toStringAsFixed(0)}).");
      } else {
        forces.add("Style tactique : La vitesse offensive (${avgVitesseAtt.toStringAsFixed(0)}) est idéale pour la 'Contre-attaque'.");
      }
    }
  }
  
  void _analyzeRoleFit() {
    // ... (Logique inchangée de la version précédente) ...
    List<MapEntry<String, double>> playerRoleScores = [];
    
    for (final entry in _startersByPoste.entries) {
      final playerWithStats = entry.value;
      final role = tacticsState.assignedRolesByPlayerId[playerWithStats.joueur.id];
      
      if (role == null || playerWithStats.stats == null) continue;
      
      final keyStats = _getKeyStatsForRole(role.role);
      final score = _calculateRoleScore(playerWithStats.stats, keyStats);
      playerRoleScores.add(MapEntry(playerWithStats.joueur.nom, score));

      final posteNaturel = playerWithStats.joueur.postes.first.name;
      if (posteNaturel != role.poste) {
        faiblesses.add("Positionnement : ${playerWithStats.joueur.nom} (${posteNaturel}) joue hors-poste en tant que ${role.poste}.");
      }
    }
    
    playerRoleScores.sort((a, b) => a.value.compareTo(b.value));
    
    final bestFits = playerRoleScores.reversed.take(3).where((e) => e.value > 75);
    final worstFits = playerRoleScores.take(3).where((e) => e.value < 60);

    if (bestFits.isNotEmpty) {
      forces.add("Excellente adéquation de rôle pour : ${bestFits.map((e) => "${e.key} (${e.value.toStringAsFixed(0)})").join(', ')}.");
    }
    if (worstFits.isNotEmpty) {
      faiblesses.add("Faible adéquation de rôle pour : ${worstFits.map((e) => "${e.key} (${e.value.toStringAsFixed(0)})").join(', ')}.");
    }
  }
  
  // NOUVELLE MÉTHODE
  void _analyzeKeyPlayerDependency() {
    for (final entry in _startersByPoste.entries) {
      final posteKey = entry.key; // e.g., 'DC1'
      final starter = entry.value;
      final genericPoste = _getGenericPoste(starter.joueur.postes.first.name);

      // Trouver tous les remplaçants pouvant jouer à ce poste
      final backups = _substitutes
          .where((p) => p.joueur.postes.any((poste) => _getGenericPoste(poste.name) == genericPoste))
          .toList();
          
      if (backups.isEmpty) {
        manques.add("Dépendance : Aucun remplaçant trouvé pour ${starter.joueur.nom} (poste $genericPoste).");
        continue;
      }
      
      backups.sort((a, b) => b.joueur.niveauActuel.compareTo(a.joueur.niveauActuel));
      final bestBackup = backups.first;
      
      final diff = starter.joueur.niveauActuel - bestBackup.joueur.niveauActuel;
      
      if (diff > 15) {
        faiblesses.add("Dépendance Élevée : ${starter.joueur.nom} (${starter.joueur.niveauActuel}) est irremplaçable. Le meilleur remplaçant (${bestBackup.joueur.nom}, ${bestBackup.joueur.niveauActuel}) est ${diff} points plus faible.");
      }
    }
  }
  
  String _getGenericPoste(String poste) {
    if (poste == 'G') return 'G';
    if (poste.startsWith('D')) return 'DEF';
    if (poste.startsWith('M')) return 'MIL';
    if (poste.startsWith('B') || poste.startsWith('A')) return 'ATT';
    return 'INCONNU';
  }


  // --- Helpers (inchangés) ---

  static int _getStat(dynamic stats, String statName) {
    if (stats == null) return 0;
    try {
      final Map<String, dynamic> json;
      if (stats is StatsJoueurSm) {
        json = (stats as StatsJoueurSmModel).toMap();
      } else if (stats is StatsGardienSm) {
        json = (stats as StatsGardienSmModel).toMap();
      } else if (stats is StatsJoueurSmModel) {
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

  static double _getGeoMean(dynamic stats, List<String> statNames) {
    if (statNames.isEmpty) return 50.0;
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
    // ... (Toute la logique des rôles, inchangée) ...
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

// Classe statique pour l'ancien appel
class SMAnalyseLogic {
  static Future<AnalyseResult> analyser({
    required int saveId,
    required JoueursSmLoaded joueursState,
    required TacticsSmState tacticsState,
    required StatsJoueurSmRepositoryImpl joueurRepo,
    required StatsGardienSmRepositoryImpl gardienRepo,
    required RoleModeleSmRepositoryImpl roleRepo,
  }) async {
    final analyzer = TeamAnalyzer(
      saveId: saveId,
      joueursState: joueursState,
      tacticsState: tacticsState,
      joueurRepo: joueurRepo,
      gardienRepo: gardienRepo,
      roleRepo: roleRepo,
    );
    return analyzer.analyser();
  }
}