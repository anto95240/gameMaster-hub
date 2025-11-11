import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/domain/sm/services/tactics_optimizer.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TacticsSmBloc extends Bloc<TacticsSmEvent, TacticsSmState> {
  final JoueurSmRepositoryImpl joueurRepo;
  final StatsJoueurSmRepositoryImpl statsRepo;
  final StatsGardienSmRepositoryImpl gardienRepo;
  final RoleModeleSmRepositoryImpl roleRepo;
  final TactiqueModeleSmRepositoryImpl tactiqueModeleRepo;
  final InstructionGeneralSmRepositoryImpl instructionGeneralRepo;
  final InstructionAttaqueSmRepositoryImpl instructionAttaqueRepo;
  final InstructionDefenseSmRepositoryImpl instructionDefenseRepo;
  final TactiqueUserSmRepositoryImpl tactiqueUserRepo;
  final TactiqueJoueurSmRepositoryImpl tactiqueJoueurRepo;

  TacticsSmBloc({
    required this.joueurRepo,
    required this.statsRepo,
    required this.gardienRepo,
    required this.roleRepo,
    required this.tactiqueModeleRepo,
    required this.instructionGeneralRepo,
    required this.instructionAttaqueRepo,
    required this.instructionDefenseRepo,
    required this.tactiqueUserRepo,
    required this.tactiqueJoueurRepo,
  }) : super(const TacticsSmState()) {
    on<LoadTactics>(_onLoadTactics);
    on<OptimizeTactics>(_onOptimizeTactics);
  }

  Future<void> _onLoadTactics(LoadTactics event, Emitter<TacticsSmState> emit) async {
    emit(state.copyWith(status: TacticsStatus.loading));
    try {
      // 1. Charger la dernière tactique utilisateur
      final lastTactic = await tactiqueUserRepo.getLatest(event.saveId);
      if (lastTactic == null) {
        emit(state.copyWith(status: TacticsStatus.loaded, selectedFormation: '4-3-3'));
        return;
      }

      // 2. Charger les données associées (maintenant null-safe)
      final playersAssignments = await tactiqueJoueurRepo.getByTactiqueId(lastTactic.id, event.saveId);
      final instrGen = await instructionGeneralRepo.getInstructionByTactiqueId(lastTactic.id, event.saveId);
      final instrAtt = await instructionAttaqueRepo.getInstructionByTactiqueId(lastTactic.id, event.saveId);
      final instrDef = await instructionDefenseRepo.getInstructionByTactiqueId(lastTactic.id, event.saveId);
      final allRoles = await roleRepo.getAllRoles();

      // 3. Charger les données des joueurs (nécessaire pour le modal)
      final allPlayers = await _getCombinedPlayerData(event.saveId);
      final allPlayersMap = {for (var p in allPlayers) p.joueur.id: p};
      final allRolesMap = {for (var r in allRoles) r.id: r};
      
      // 4. Mapper les joueurs aux postes
      final Map<String, JoueurSmWithStats?> assignedPlayers = {};
      final Map<int, RoleModeleSm> assignedRoles = {};

      final postesFormation = _getPosteKeysForFormation(lastTactic.formation);
      final List<int> assignedPlayerIds = [];

      for (final assignment in playersAssignments) {
        final player = allPlayersMap[assignment.joueurId];
        if (player == null) continue;

        final role = allRolesMap[assignment.roleId];
        if (role == null) continue;

        // Tenter de trouver le poste clé exact
        String basePoste = role.poste;
        String posteKey = basePoste;
        int i = 1;
        while(assignedPlayers.containsKey(posteKey) && posteKey.contains(basePoste)) {
          posteKey = "$basePoste$i";
          i++;
        }

        // Si on ne trouve pas de clé (ex: DC1, DC2), on cherche un poste libre
        if (assignedPlayers.containsKey(posteKey)) {
           posteKey = postesFormation.firstWhere(
             (pf) => pf.startsWith(basePoste) && !assignedPlayers.containsKey(pf),
             orElse: () => posteKey // Fallback
           );
        }

        assignedPlayers[posteKey] = player;
        assignedRoles[player.joueur.id] = role;
        assignedPlayerIds.add(player.joueur.id);
      }
      
      // 5. ✅✅✅ CORRECTION 2 (Null Checks) ✅✅✅
      final stylesGen = {
        if(instrGen != null && instrGen.largeur != null && instrGen.largeur!.isNotEmpty) instrGen.largeur!: 1.0,
        if(instrGen != null && instrGen.mentalite != null && instrGen.mentalite!.isNotEmpty) instrGen.mentalite!: 1.0,
        if(instrGen != null && instrGen.tempo != null && instrGen.tempo!.isNotEmpty) instrGen.tempo!: 1.0,
        if(instrGen != null && instrGen.fluidite != null && instrGen.fluidite!.isNotEmpty) instrGen.fluidite!: 1.0,
        if(instrGen != null && instrGen.rythmeTravail != null && instrGen.rythmeTravail!.isNotEmpty) instrGen.rythmeTravail!: 1.0,
        if(instrGen != null && instrGen.creativite != null && instrGen.creativite!.isNotEmpty) instrGen.creativite!: 1.0,
      };
       final stylesAtt = {
        if(instrAtt != null && instrAtt.stylePasse != null && instrAtt.stylePasse!.isNotEmpty) instrAtt.stylePasse!: 1.0,
        if(instrAtt != null && instrAtt.styleAttaque != null && instrAtt.styleAttaque!.isNotEmpty) instrAtt.styleAttaque!: 1.0,
        if(instrAtt != null && instrAtt.attaquants != null && instrAtt.attaquants!.isNotEmpty) instrAtt.attaquants!: 1.0,
        if(instrAtt != null && instrAtt.jeuLarge != null && instrAtt.jeuLarge!.isNotEmpty) instrAtt.jeuLarge!: 1.0,
        if(instrAtt != null && instrAtt.jeuConstruction != null && instrAtt.jeuConstruction!.isNotEmpty) instrAtt.jeuConstruction!: 1.0,
        if(instrAtt != null && instrAtt.contreAttaque != null && instrAtt.contreAttaque!.isNotEmpty) instrAtt.contreAttaque!: 1.0,
      };
       final stylesDef = {
        if(instrDef != null && instrDef.pressing != null && instrDef.pressing!.isNotEmpty) instrDef.pressing!: 1.0,
        if(instrDef != null && instrDef.styleTacle != null && instrDef.styleTacle!.isNotEmpty) instrDef.styleTacle!: 1.0,
        if(instrDef != null && instrDef.ligneDefensive != null && instrDef.ligneDefensive!.isNotEmpty) instrDef.ligneDefensive!: 1.0,
        if(instrDef != null && instrDef.gardienLibero != null && instrDef.gardienLibero!.isNotEmpty) instrDef.gardienLibero!: 1.0,
        if(instrDef != null && instrDef.perteTemps != null && instrDef.perteTemps!.isNotEmpty) instrDef.perteTemps!: 1.0,
      };
      // ✅✅✅ FIN CORRECTION 2 ✅✅✅

      emit(TacticsSmState(
        status: TacticsStatus.loaded,
        selectedFormation: lastTactic.formation,
        assignedPlayersByPoste: assignedPlayers,
        assignedRolesByPlayerId: assignedRoles,
        stylesGeneral: stylesGen,
        stylesAttack: stylesAtt,
        stylesDefense: stylesDef,
      ));

    } catch (e) {
      emit(state.copyWith(status: TacticsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onOptimizeTactics(OptimizeTactics event, Emitter<TacticsSmState> emit) async {
    emit(state.copyWith(status: TacticsStatus.loading));
    try {
      final optimizer = TacticsOptimizer(
        joueurRepo: joueurRepo,
        statsRepo: statsRepo,
        gardienRepo: gardienRepo,
        roleRepo: roleRepo,
        tactiqueModeleRepo: tactiqueModeleRepo,
        instructionGeneralRepo: instructionGeneralRepo,
        instructionAttaqueRepo: instructionAttaqueRepo,
        instructionDefenseRepo: instructionDefenseRepo,
      );
      final result = await optimizer.optimize(saveId: event.saveId);
      final authUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final supabaseClient = Supabase.instance.client;

      // 1. Nettoyer les anciennes données tactiques
      await supabaseClient.from('tactique_joueur_sm').delete().eq('save_id', event.saveId);
      await supabaseClient.from('instruction_attaque_sm').delete().eq('save_id', event.saveId);
      await supabaseClient.from('instruction_defense_sm').delete().eq('save_id', event.saveId);
      await supabaseClient.from('instruction_general_sm').delete().eq('save_id', event.saveId);
      await supabaseClient.from('tactique_user_sm').delete().eq('save_id', event.saveId);

      // 2. Insérer la nouvelle tactique utilisateur
      final newTactiqueId = await tactiqueUserRepo.insert(TactiqueUserSmModel(
        id: 0,
        formation: result.formation,
        modeleId: result.modeleId,
        nom: 'Optimisée ${DateTime.now().toIso8601String()}',
        userId: authUserId,
        saveId: event.saveId,
      ));

      // 3. Insérer les assignations joueurs-rôles
      for (final entry in result.joueurIdToRoleId.entries) {
        await tactiqueJoueurRepo.insert(TactiqueJoueurSmModel(
          id: 0,
          tactiqueId: newTactiqueId,
          joueurId: entry.key,
          roleId: entry.value,
          userId: authUserId,
          saveId: event.saveId,
        ));
      }

      // 4. Insérer les instructions (maintenant 17)
      await instructionGeneralRepo.insertInstruction(InstructionGeneralSmModel(
        id: 0,
        tactiqueId: newTactiqueId,
        saveId: event.saveId,
        userId: authUserId,
        largeur: result.styles.general.keys.firstWhere((k) => k.startsWith('Largeur:'), orElse: () => ''),
        mentalite: result.styles.general.keys.firstWhere((k) => k.startsWith('Mentalité:'), orElse: () => ''),
        tempo: result.styles.general.keys.firstWhere((k) => k.startsWith('Tempo:'), orElse: () => ''),
        fluidite: result.styles.general.keys.firstWhere((k) => k.startsWith('Fluidité:'), orElse: () => ''),
        rythmeTravail: result.styles.general.keys.firstWhere((k) => k.startsWith('Rythme de travail:'), orElse: () => ''),
        creativite: result.styles.general.keys.firstWhere((k) => k.startsWith('Créativité:'), orElse: () => ''),
      ));

      await instructionAttaqueRepo.insertInstruction(InstructionAttaqueSmModel(
        id: 0,
        tactiqueId: newTactiqueId,
        saveId: event.saveId,
        userId: authUserId,
        stylePasse: result.styles.attack.keys.firstWhere((k) => k.startsWith('Style de passe:'), orElse: () => ''),
        styleAttaque: result.styles.attack.keys.firstWhere((k) => k.startsWith('Style d\'attaque:'), orElse: () => ''),
        attaquants: result.styles.attack.keys.firstWhere((k) => k.startsWith('Attaquants:'), orElse: () => ''),
        jeuLarge: result.styles.attack.keys.firstWhere((k) => k.startsWith('Jeu large:'), orElse: () => ''),
        jeuConstruction: result.styles.attack.keys.firstWhere((k) => k.startsWith('Jeu en contruction:'), orElse: () => ''), // Note: "contruction"
        contreAttaque: result.styles.attack.keys.firstWhere((k) => k.startsWith('Contre-attaque:'), orElse: () => ''),
      ));

      await instructionDefenseRepo.insertInstruction(InstructionDefenseSmModel(
        id: 0,
        tactiqueId: newTactiqueId,
        saveId: event.saveId,
        userId: authUserId,
        pressing: result.styles.defense.keys.firstWhere((k) => k.startsWith('Pressing:'), orElse: () => ''),
        styleTacle: result.styles.defense.keys.firstWhere((k) => k.startsWith('Style tacle:'), orElse: () => ''),
        ligneDefensive: result.styles.defense.keys.firstWhere((k) => k.startsWith('Ligne défensive:'), orElse: () => ''),
        gardienLibero: result.styles.defense.keys.firstWhere((k) => k.startsWith('Gardien libéro:'), orElse: () => ''),
        perteTemps: result.styles.defense.keys.firstWhere((k) => k.startsWith('Perte de temps:'), orElse: () => ''),
      ));

      // 5. Préparer le nouvel état pour l'interface
      final allRoles = await roleRepo.getAllRoles();
      final allRolesMap = {for (var r in allRoles) r.id: r};
      
      final Map<String, JoueurSmWithStats?> assignedPlayers = {};
      final Map<int, RoleModeleSm> assignedRoles = {};

      for (final entry in result.elevenByPoste.entries) {
        final posteKey = entry.key; // "DC1"
        final player = entry.value;
        
        assignedPlayers[posteKey] = JoueurSmWithStats(joueur: player.joueur, stats: player.stats);
        
        final roleId = result.joueurIdToRoleId[player.joueur.id];
        if(roleId != null && allRolesMap.containsKey(roleId)) {
          assignedRoles[player.joueur.id] = allRolesMap[roleId]!;
        }
      }

      // 6. Émettre le nouvel état
      emit(TacticsSmState(
        status: TacticsStatus.loaded,
        selectedFormation: result.formation,
        stylesGeneral: result.styles.general,
        stylesAttack: result.styles.attack,
        stylesDefense: result.styles.defense,
        assignedPlayersByPoste: assignedPlayers,
        assignedRolesByPlayerId: assignedRoles,
      ));

    } catch (e) {
      emit(state.copyWith(status: TacticsStatus.error, errorMessage: e.toString()));
    }
  }

  // Helper pour mapper les clés de poste (pour le chargement)
  List<String> _getPosteKeysForFormation(String formation) {
    final map = {
      '4-3-3': ['GK', 'DG', 'DC1', 'DC2', 'DD', 'MC1', 'MC2', 'MC3', 'AG', 'AD', 'BU'],
      '4-4-2': ['GK', 'DG', 'DC1', 'DC2', 'DD', 'MG', 'MC1', 'MC2', 'MD', 'BU1', 'BU2'],
      '5-3-2': ['GK', 'DG', 'DC1', 'DC2', 'DC3', 'DD', 'MC1', 'MC2', 'MC3', 'BU1', 'BU2'],
      '3-5-2': ['GK', 'DC1', 'DC2', 'DC3', 'MG', 'MC1', 'MC2', 'MC3', 'MD', 'BU1', 'BU2'],
      '4-2-3-1': ['GK', 'DG', 'DC1', 'DC2', 'DD', 'MDC1', 'MDC2', 'MOC', 'AG', 'AD', 'BU'],
    };
    return map[formation] ?? map['4-3-3']!; // Fallback
  }

  // Helper pour récupérer les données combinées (utilisé par _onLoadTactics)
  Future<List<JoueurSmWithStats>> _getCombinedPlayerData(int saveId) async {
    final joueurs = await joueurRepo.getAllJoueurs(saveId);
    final List<JoueurSmWithStats> joueursWithStats = [];

    for (final joueur in joueurs) {
      final bool isGK = joueur.postes.any((p) => p.name == 'GK');
      final dynamic stats = isGK
          ? await gardienRepo.getStatsByJoueurId(joueur.id, saveId)
          : await statsRepo.getStatsByJoueurId(joueur.id, saveId);
      joueursWithStats.add(JoueurSmWithStats(joueur: joueur, stats: stats));
    }
    return joueursWithStats;
  }
}