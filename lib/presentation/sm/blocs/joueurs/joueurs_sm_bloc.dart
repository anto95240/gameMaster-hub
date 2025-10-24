import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';
import 'package:gamemaster_hub/domain/sm/entities/stats_joueur_sm.dart';
import 'package:gamemaster_hub/domain/sm/entities/stats_gardien_sm.dart';
import 'package:gamemaster_hub/domain/sm/repositories/joueur_sm_repository.dart';
import 'package:gamemaster_hub/domain/sm/repositories/stats_joueur_sm_repository.dart';
import 'package:gamemaster_hub/domain/sm/repositories/stats_gardien_sm_repository.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

class JoueursSmBloc extends Bloc<JoueursSmEvent, JoueursSmState> {
  final JoueurSmRepository joueurRepository;
  final StatsJoueurSmRepository statsRepository;
  final StatsGardienSmRepository gardienRepository;

  JoueursSmBloc({
    required this.joueurRepository,
    required this.statsRepository,
    required this.gardienRepository,
  }) : super(JoueursSmInitial()) {
    on<LoadJoueursSmEvent>(_onLoadJoueurs);
    on<AddJoueurSmEvent>(_onAddJoueur);
    on<UpdateJoueurSmEvent>(_onUpdateJoueur);
    on<DeleteJoueurSmEvent>(_onDeleteJoueur);
    on<FilterJoueursSmEvent>(_onFilterJoueurs);
    on<SortJoueursSmEvent>(_onSortJoueurs);
  }

  // 🟢 Charger les joueurs + leurs stats
  Future<void> _onLoadJoueurs(
      LoadJoueursSmEvent event, Emitter<JoueursSmState> emit) async {
    emit(JoueursSmLoading());
    try {
      final joueurs = await joueurRepository.getAllJoueurs(event.saveId);
      final List<JoueurSmWithStats> joueursWithStats = [];

      for (final joueur in joueurs) {
        final bool isGK = joueur.postes.any((p) => p.name == 'GK');

        final dynamic stats = isGK
            ? await gardienRepository.getStatsByJoueurId(joueur.id, event.saveId)
            : await statsRepository.getStatsByJoueurId(joueur.id, event.saveId);

        joueursWithStats.add(JoueurSmWithStats(joueur: joueur, stats: stats));
      }

      emit(JoueursSmLoaded(joueurs: joueursWithStats));
    } catch (e) {
      emit(JoueursSmError('Erreur lors du chargement des joueurs : $e'));
    }
  }

  // 🟡 Ajouter un joueur
  Future<void> _onAddJoueur(
      AddJoueurSmEvent event, Emitter<JoueursSmState> emit) async {
    try {
      await joueurRepository.insertJoueur(event.joueur);

      final isGK = event.joueur.postes.any((p) => p.name == 'GK');

      // Crée automatiquement des stats de base après ajout du joueur
      if (isGK) {
        final newStats = StatsGardienSm(
          id: 0,
          joueurId: event.joueur.id,
          saveId: event.saveId,
        );
        await gardienRepository.insertStats(newStats);
      } else {
        final newStats = StatsJoueurSm(
          id: 0,
          joueurId: event.joueur.id,
          saveId: event.saveId,
          marquage: 0,
          deplacement: 0,
          frappesLointaines: 0,
          passesLongues: 0,
          coupsFrancs: 0,
          tacles: 0,
          finition: 0,
          centres: 0,
          passes: 0,
          corners: 0,
          positionnement: 0,
          dribble: 0,
          controle: 0,
          penalties: 0,
          creativite: 0,
          stabiliteAerienne: 0,
          vitesse: 0,
          endurance: 0,
          force: 0,
          distanceParcourue: 0,
          agressivite: 0,
          sangFroid: 0,
          concentration: 0,
          flair: 0,
          leadership: 0,
        );
        await statsRepository.insertStats(newStats);
      }

      add(LoadJoueursSmEvent(event.saveId));
    } catch (e) {
      emit(JoueursSmError('Erreur lors de l’ajout : $e'));
    }
  }

  // 🔵 Mettre à jour un joueur et ses stats
  Future<void> _onUpdateJoueur(
      UpdateJoueurSmEvent event, Emitter<JoueursSmState> emit) async {
    try {
      await joueurRepository.updateJoueur(event.joueur);
      final bool isGK = event.joueur.postes.any((p) => p.name == 'GK');

      if (event.stats.isNotEmpty) {
        if (isGK) {
          final existing =
              await gardienRepository.getStatsByJoueurId(event.joueur.id, event.saveId);

          final updated = StatsGardienSm(
            id: existing?.id ?? 0,
            joueurId: event.joueur.id,
            saveId: event.saveId,
            autoriteSurface: event.stats['autorite_surface'] ?? 0,
            distribution: event.stats['distribution'] ?? 0,
            captation: event.stats['captation'] ?? 0,
            duels: event.stats['duels'] ?? 0,
            arrets: event.stats['arrets'] ?? 0,
            positionnement: event.stats['positionnement'] ?? 0,
            penalties: event.stats['penalties'] ?? 0,
            stabiliteAerienne: event.stats['stabilite_aerienne'] ?? 0,
            vitesse: event.stats['vitesse'] ?? 0,
            force: event.stats['force'] ?? 0,
            agressivite: event.stats['agressivite'] ?? 0,
            sangFroid: event.stats['sang_froid'] ?? 0,
            concentration: event.stats['concentration'] ?? 0,
            leadership: event.stats['leadership'] ?? 0,
          );

          if (existing == null) {
            await gardienRepository.insertStats(updated);
          } else {
            await gardienRepository.updateStats(updated);
          }
        } else {
          final existing =
              await statsRepository.getStatsByJoueurId(event.joueur.id, event.saveId);

          final updated = StatsJoueurSm(
            id: existing?.id ?? 0,
            joueurId: event.joueur.id,
            saveId: event.saveId,
            marquage: event.stats['marquage'] ?? 0,
            deplacement: event.stats['deplacement'] ?? 0,
            frappesLointaines: event.stats['frappes_lointaines'] ?? 0,
            passesLongues: event.stats['passes_longues'] ?? 0,
            coupsFrancs: event.stats['coups_francs'] ?? 0,
            tacles: event.stats['tacles'] ?? 0,
            finition: event.stats['finition'] ?? 0,
            centres: event.stats['centres'] ?? 0,
            passes: event.stats['passes'] ?? 0,
            corners: event.stats['corners'] ?? 0,
            positionnement: event.stats['positionnement'] ?? 0,
            dribble: event.stats['dribble'] ?? 0,
            controle: event.stats['controle'] ?? 0,
            penalties: event.stats['penalties'] ?? 0,
            creativite: event.stats['creativite'] ?? 0,
            stabiliteAerienne: event.stats['stabilite_aerienne'] ?? 0,
            vitesse: event.stats['vitesse'] ?? 0,
            endurance: event.stats['endurance'] ?? 0,
            force: event.stats['force'] ?? 0,
            distanceParcourue: event.stats['distance_parcourue'] ?? 0,
            agressivite: event.stats['agressivite'] ?? 0,
            sangFroid: event.stats['sang_froid'] ?? 0,
            concentration: event.stats['concentration'] ?? 0,
            flair: event.stats['flair'] ?? 0,
            leadership: event.stats['leadership'] ?? 0,
          );

          if (existing == null) {
            await statsRepository.insertStats(updated);
          } else {
            await statsRepository.updateStats(updated);
          }
        }
      }

      add(LoadJoueursSmEvent(event.saveId));
    } catch (e) {
      emit(JoueursSmError('Erreur lors de la mise à jour : $e'));
    }
  }

  // 🔴 Supprimer un joueur
  Future<void> _onDeleteJoueur(
      DeleteJoueurSmEvent event, Emitter<JoueursSmState> emit) async {
    try {
      await joueurRepository.deleteJoueur(event.joueurId);
      add(LoadJoueursSmEvent(event.saveId));
    } catch (e) {
      emit(JoueursSmError('Erreur lors de la suppression : $e'));
    }
  }

  // 🔍 Filtrer les joueurs
  Future<void> _onFilterJoueurs(
      FilterJoueursSmEvent event, Emitter<JoueursSmState> emit) async {
    if (state is JoueursSmLoaded) {
      final current = state as JoueursSmLoaded;
      emit(current.copyWith(
        selectedPosition: event.position,
        searchQuery: event.searchQuery,
      ));
    }
  }

  // 🔽 Trier les joueurs
  Future<void> _onSortJoueurs(
      SortJoueursSmEvent event, Emitter<JoueursSmState> emit) async {
    if (state is JoueursSmLoaded) {
      final current = state as JoueursSmLoaded;
      SortField? sortField;
      bool sortAscending = current.sortAscending;

      switch (event.sortField) {
        case 'Nom':
          sortField = SortField.name;
          break;
        case 'Note':
          sortField = SortField.rating;
          break;
        case 'Âge':
          sortField = SortField.age;
          break;
        case 'Potentiel':
          sortField = SortField.potential;
          break;
        case 'Transfert':
          sortField = SortField.transferValue;
          break;
        case 'Salaire':
          sortField = SortField.salary;
          break;
        default:
          sortField = SortField.name;
      }

      if (sortField == current.sortField) {
        sortAscending = !sortAscending;
      } else {
        sortAscending = true;
      }

      emit(current.copyWith(
        sortField: sortField,
        sortAscending: sortAscending,
      ));
    }
  }
}
