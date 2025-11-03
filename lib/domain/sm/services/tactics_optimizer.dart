import 'package:gamemaster_hub/domain/domain_export.dart';

class OptimizedStyles {
  final Map<String, double> general; // name -> score
  final Map<String, double> attack;
  final Map<String, double> defense;
  OptimizedStyles({required this.general, required this.attack, required this.defense});
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

class TacticsOptimizer {
  final JoueurSmRepository joueurRepo;
  final StatsJoueurSmRepository statsRepo;
  final StatsGardienSmRepository gardienRepo;
  final RoleModeleSmRepository roleRepo;
  final TactiqueModeleSmRepository tactiqueModeleRepo;

  TacticsOptimizer({
    required this.joueurRepo,
    required this.statsRepo,
    required this.gardienRepo,
    required this.roleRepo,
    required this.tactiqueModeleRepo,
  });

  Future<OptimizedTacticsResult> optimize({required int saveId}) async {
    final joueurs = await joueurRepo.getAllJoueurs(saveId);
    final statsList = await statsRepo.getAllStats(saveId);

    // Basic heuristic: ensure 1 GK then choose a default formation 4-3-3 if possible
    String chosenFormation = '4-3-3';
    int? modeleId;
    final tactiques = await tactiqueModeleRepo.getAllTactiques();
    if (tactiques.isNotEmpty) {
      final first = tactiques.first;
      chosenFormation = first.formation.isNotEmpty ? first.formation : chosenFormation;
      modeleId = first.id;
    } else {
      chosenFormation = '4-3-3';
      modeleId = -1;
    }

    // Assign roles by simple position-based mapping using postes and a default role per poste
    final roles = await roleRepo.getAllRoles();
    final Map<String, RoleModeleSm> defaultRoleByPoste = {};
    for (final r in roles) {
      defaultRoleByPoste.putIfAbsent(r.poste, () => r);
    }

    // Pick 11 best by naive score: niveauActuel + key stat if available
    double scoreFor(int joueurId) {
      final j = joueurs.firstWhere((e) => e.id == joueurId);
      final s = statsList.where((x) => x.joueurId == joueurId).cast<StatsJoueurSm?>().firstOrNull;
      final base = j.niveauActuel.toDouble();
      final extra = s == null ? 0.0 : ((s.passes) + (s.positionnement) + (s.vitesse)) / 3.0;
      return base + extra * 0.2;
    }

    final sorted = List.of(joueurs)..sort((a, b) => scoreFor(b.id).compareTo(scoreFor(a.id)));
    final eleven = sorted.take(11).toList();

    final Map<int, int> joueurToRole = {};
    for (final j in eleven) {
      final poste = j.postes.isNotEmpty ? j.postes.first.name : 'GK';
      final role = defaultRoleByPoste[poste];
      if (role != null) {
        joueurToRole[j.id] = role.id;
      }
    }

    // Styles: pick placeholders with simple scores
    final styles = OptimizedStyles(
      general: {
        'largeur: équilibrée': 0.7,
        'mentalité: positive': 0.8,
        'tempo: normal': 0.6,
      },
      attack: {
        'style de passe: mixte': 0.75,
        'jeu de construction: progressif': 0.7,
        'contre-attaque: occasionnelle': 0.6,
      },
      defense: {
        'pressing: standard': 0.65,
        'ligne défensive: médiane': 0.7,
        'style tacle: mesuré': 0.6,
      },
    );

    return OptimizedTacticsResult(
      formation: chosenFormation,
      modeleId: modeleId,
      joueurIdToRoleId: joueurToRole,
      styles: styles,
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}


