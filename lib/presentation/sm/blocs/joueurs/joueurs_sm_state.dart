import 'package:equatable/equatable.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';
import 'package:gamemaster_hub/domain/sm/entities/stats_joueur_sm.dart';

enum SortField {
  name,
  rating,
  age,
  potential,
  transferValue,
  salary,
}

class JoueurSmWithStats {
  final JoueurSm joueur;
  final StatsJoueurSm? stats;

  JoueurSmWithStats({
    required this.joueur,
    this.stats,
  });

  double get averageRating {
    if (stats == null) return 0.0;
    final allStats = [
      stats!.marquage,
      stats!.deplacement,
      stats!.frappesLointaines,
      stats!.passesLongues,
      stats!.coupsFrancs,
      stats!.tacles,
      stats!.finition,
      stats!.centres,
      stats!.passes,
      stats!.corners,
      stats!.positionnement,
      stats!.dribble,
      stats!.controle,
      stats!.penalties,
      stats!.creativite,
      stats!.stabiliteAerienne,
      stats!.vitesse,
      stats!.endurance,
      stats!.force,
      stats!.distanceParcourue,
      stats!.agressivite,
      stats!.sangFroid,
      stats!.concentration,
      stats!.flair,
      stats!.leadership,
    ];
    final sum = allStats.reduce((a, b) => a + b);
    return sum / allStats.length;
  }
}

abstract class JoueursSmState extends Equatable {
  const JoueursSmState();

  @override
  List<Object?> get props => [];
}

class JoueursSmInitial extends JoueursSmState {}

class JoueursSmLoading extends JoueursSmState {}

class JoueursSmLoaded extends JoueursSmState {
  final List<JoueurSmWithStats> joueurs;
  final String selectedPosition;
  final String searchQuery;
  final SortField? sortField;
  final bool sortAscending;

  const JoueursSmLoaded({
    required this.joueurs,
    this.selectedPosition = 'Tous',
    this.searchQuery = '',
    this.sortField,
    this.sortAscending = true,
  });

  List<JoueurSmWithStats> get filteredJoueurs {
    var filtered = joueurs.where((item) {
      final matchesPosition = selectedPosition == 'Tous' ||
          _matchesPosition(item.joueur, selectedPosition);
      final matchesSearch = searchQuery.isEmpty ||
          item.joueur.nom.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesPosition && matchesSearch;
    }).toList();

    if (sortField != null) {
      filtered.sort((a, b) {
        int comparison = 0;
        switch (sortField!) {
          case SortField.name:
            comparison = a.joueur.nom.compareTo(b.joueur.nom);
            break;
          case SortField.rating:
            comparison = a.averageRating.compareTo(b.averageRating);
            break;
          case SortField.age:
            comparison = a.joueur.age.compareTo(b.joueur.age);
            break;
          case SortField.potential:
            comparison = a.joueur.potentiel.compareTo(b.joueur.potentiel);
            break;
          case SortField.transferValue:
            comparison = a.joueur.montantTransfert.compareTo(b.joueur.montantTransfert);
            break;
          case SortField.salary:
            comparison = a.joueur.salaire.compareTo(b.joueur.salaire);
            break;
        }
        return sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  bool _matchesPosition(JoueurSm joueur, String position) {
    final filters = _getPositionFilter(position);
    return filters.any((pos) => joueur.postes.any((p) => p.name == pos));
  }

  List<String> _getPositionFilter(String position) {
    switch (position) {
      case 'Gardien':
        return ['GK'];
      case 'Défenseur':
        return ['DC', 'DG', 'DD', 'DOG', 'DOD'];
      case 'Milieu':
        return ['MC', 'MDC', 'MOC', 'MD', 'MG'];
      case 'Attaquant':
        return ['BU', 'MOD', 'MOG'];
      default:
        return [];
    }
  }

  JoueursSmLoaded copyWith({
    List<JoueurSmWithStats>? joueurs,
    String? selectedPosition,
    String? searchQuery,
    SortField? sortField,
    bool? sortAscending,
  }) {
    return JoueursSmLoaded(
      joueurs: joueurs ?? this.joueurs,
      selectedPosition: selectedPosition ?? this.selectedPosition,
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  @override
  List<Object?> get props => [joueurs, selectedPosition, searchQuery, sortField, sortAscending];
}

class JoueursSmError extends JoueursSmState {
  final String message;

  const JoueursSmError(this.message);

  @override
  List<Object?> get props => [message];
}