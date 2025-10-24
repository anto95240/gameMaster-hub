import 'package:equatable/equatable.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

enum SortField { name, rating, age, potential, transferValue, salary }

class JoueurSmWithStats {
  final JoueurSm joueur;
  final dynamic stats;

  JoueurSmWithStats({required this.joueur, this.stats});

  double get averageRating {
    if (stats == null) return 0.0;
    try {
      final values = stats.toJson().values
          .whereType<num>()
          .map((v) => v.toDouble())
          .toList();
      if (values.isEmpty) return 0.0;
      return values.reduce((a, b) => a + b) / values.length;
    } catch (_) {
      return 0.0;
    }
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
        int comp = 0;
        switch (sortField!) {
          case SortField.name:
            comp = a.joueur.nom.compareTo(b.joueur.nom);
            break;
          case SortField.rating:
            comp = a.averageRating.compareTo(b.averageRating);
            break;
          case SortField.age:
            comp = a.joueur.age.compareTo(b.joueur.age);
            break;
          case SortField.potential:
            comp = a.joueur.potentiel.compareTo(b.joueur.potentiel);
            break;
          case SortField.transferValue:
            comp = a.joueur.montantTransfert.compareTo(b.joueur.montantTransfert);
            break;
          case SortField.salary:
            comp = a.joueur.salaire.compareTo(b.joueur.salaire);
            break;
        }
        return sortAscending ? comp : -comp;
      });
    }

    return filtered;
  }

  bool _matchesPosition(JoueurSm joueur, String pos) {
    switch (pos) {
      case 'Gardien':
        return joueur.postes.any((p) => p.name == 'GK');
      case 'Défenseur':
        return joueur.postes.any((p) => ['DC', 'DG', 'DD'].contains(p.name));
      case 'Milieu':
        return joueur.postes.any((p) => ['MC', 'MDC', 'MOC'].contains(p.name));
      case 'Attaquant':
        return joueur.postes.any((p) => ['BU', 'MOG', 'MOD'].contains(p.name));
      default:
        return true;
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
  List<Object?> get props =>
      [joueurs, selectedPosition, searchQuery, sortField, sortAscending];
}

class JoueursSmError extends JoueursSmState {
  final String message;
  const JoueursSmError(this.message);

  @override
  List<Object?> get props => [message];
}
