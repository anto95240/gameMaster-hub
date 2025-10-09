import 'package:equatable/equatable.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';

abstract class JoueursSmEvent extends Equatable {
  const JoueursSmEvent();

  @override
  List<Object?> get props => [];
}

// 🔹 Load joueurs
class LoadJoueursSmEvent extends JoueursSmEvent {
  final int saveId;

  const LoadJoueursSmEvent(this.saveId);

  @override
  List<Object?> get props => [saveId];
}

// 🔹 Ajouter un joueur
class AddJoueurSmEvent extends JoueursSmEvent {
  final JoueurSm joueur;
  final int saveId;

  const AddJoueurSmEvent(this.joueur, this.saveId);

  @override
  List<Object?> get props => [joueur, saveId];
}

// 🔹 Mettre à jour un joueur
class UpdateJoueurSmEvent extends JoueursSmEvent {
  final JoueurSm joueur;
  final Map<String, int> stats;
  final int saveId;

  const UpdateJoueurSmEvent(this.joueur, this.stats, this.saveId);

  @override
  List<Object?> get props => [joueur, stats, saveId];
}

// 🔹 Supprimer un joueur
class DeleteJoueurSmEvent extends JoueursSmEvent {
  final int joueurId;
  final int saveId;

  const DeleteJoueurSmEvent(this.joueurId, this.saveId);

  @override
  List<Object?> get props => [joueurId, saveId];
}

// 🔹 Filtrer les joueurs (peut rester inchangé)
class FilterJoueursSmEvent extends JoueursSmEvent {
  final String position;
  final String searchQuery;

  const FilterJoueursSmEvent({
    required this.position,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [position, searchQuery];
}

// 🔹 Trier les joueurs (peut rester inchangé)
class SortJoueursSmEvent extends JoueursSmEvent {
  final String sortField;
  final bool ascending;

  const SortJoueursSmEvent({
    required this.sortField,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [sortField, ascending];
}
