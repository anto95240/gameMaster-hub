import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/sm/repositories/joueur_sm_repository.dart';
import 'package:gamemaster_hub/domain/sm/repositories/stats_joueur_sm_repository.dart';
import 'joueurs_sm_event.dart';
import 'joueurs_sm_state.dart';

class JoueursSmBloc extends Bloc<JoueursSmEvent, JoueursSmState> {
  final JoueurSmRepository joueurRepository;
  final StatsJoueurSmRepository statsRepository;

  JoueursSmBloc({
    required this.joueurRepository,
    required this.statsRepository,
  }) : super(JoueursSmInitial()) {
    on<LoadJoueursSmEvent>(_onLoadJoueurs);
    on<AddJoueurSmEvent>(_onAddJoueur);
    on<UpdateJoueurSmEvent>(_onUpdateJoueur);
    on<DeleteJoueurSmEvent>(_onDeleteJoueur);
    on<FilterJoueursSmEvent>(_onFilterJoueurs);
    on<SortJoueursSmEvent>(_onSortJoueurs);
  }

  Future<void> _onLoadJoueurs(
    LoadJoueursSmEvent event,
    Emitter<JoueursSmState> emit,
  ) async {
    emit(JoueursSmLoading());
    try {
      final joueurs = await joueurRepository.getAllJoueurs(event.saveId);
      final joueursWithStats = <JoueurSmWithStats>[];

      for (final joueur in joueurs) {
        final stats = await statsRepository.getStatsByJoueurId(joueur.id, event.saveId);
        joueursWithStats.add(JoueurSmWithStats(
          joueur: joueur,
          stats: stats,
        ));
      }

      emit(JoueursSmLoaded(joueurs: joueursWithStats));
    } catch (e) {
      emit(JoueursSmError(e.toString()));
    }
  }

  Future<void> _onAddJoueur(
    AddJoueurSmEvent event,
    Emitter<JoueursSmState> emit,
  ) async {
    try {
      await joueurRepository.insertJoueur(event.joueur);
      add(LoadJoueursSmEvent(event.joueur.saveId));
    } catch (e) {
      emit(JoueursSmError(e.toString()));
    }
  }

  Future<void> _onUpdateJoueur(
    UpdateJoueurSmEvent event,
    Emitter<JoueursSmState> emit,
  ) async {
    try {
      await joueurRepository.updateJoueur(event.joueur);
      if (event.stats.isNotEmpty) {
        final stats = await statsRepository.getStatsByJoueurId(event.joueur.id, event.joueur.saveId);
        if (stats != null) {
          final updatedStats = stats.copyWith(
            marquage: event.stats['marquage'],
            deplacement: event.stats['deplacement'],
            frappesLointaines: event.stats['frappes_lointaines'],
            passesLongues: event.stats['passes_longues'],
            coupsFrancs: event.stats['coups_francs'],
            tacles: event.stats['tacles'],
            finition: event.stats['finition'],
            centres: event.stats['centres'],
            passes: event.stats['passes'],
            corners: event.stats['corners'],
            positionnement: event.stats['positionnement'],
            dribble: event.stats['dribble'],
            controle: event.stats['controle'],
            penalties: event.stats['penalties'],
            creativite: event.stats['creativite'],
            stabiliteAerienne: event.stats['stabilite_aerienne'],
            vitesse: event.stats['vitesse'],
            endurance: event.stats['endurance'],
            force: event.stats['force'],
            distanceParcourue: event.stats['distance_parcourue'],
            agressivite: event.stats['agressivite'],
            sangFroid: event.stats['sang_froid'],
            concentration: event.stats['concentration'],
            flair: event.stats['flair'],
            leadership: event.stats['leadership'],
          );
          await statsRepository.updateStats(updatedStats);
        }
      }
      add(LoadJoueursSmEvent(event.joueur.saveId));
    } catch (e) {
      emit(JoueursSmError(e.toString()));
    }
  }

  Future<void> _onDeleteJoueur(
    DeleteJoueurSmEvent event,
    Emitter<JoueursSmState> emit,
  ) async {
    try {
      await joueurRepository.deleteJoueur(event.joueurId);
      add(LoadJoueursSmEvent(event.saveId));
    } catch (e) {
      emit(JoueursSmError(e.toString()));
    }
  }

  Future<void> _onFilterJoueurs(
    FilterJoueursSmEvent event,
    Emitter<JoueursSmState> emit,
  ) async {
    if (state is JoueursSmLoaded) {
      final currentState = state as JoueursSmLoaded;
      emit(currentState.copyWith(
        selectedPosition: event.position,
        searchQuery: event.searchQuery,
      ));
    }
  }

  Future<void> _onSortJoueurs(
    SortJoueursSmEvent event,
    Emitter<JoueursSmState> emit,
  ) async {
    if (state is JoueursSmLoaded) {
      final currentState = state as JoueursSmLoaded;
      SortField? sortField;
      bool sortAscending = currentState.sortAscending;

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
          sortField = currentState.sortField ?? SortField.name;
      }

      if (sortField == currentState.sortField) {
        sortAscending = !sortAscending;
      } else {
        sortAscending = true;
      }

      emit(currentState.copyWith(
        sortField: sortField,
        sortAscending: sortAscending,
      ));
    }
  }
}
