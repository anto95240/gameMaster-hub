import 'package:equatable/equatable.dart';

abstract class SavesEvent extends Equatable {
  const SavesEvent();

  @override
  List<Object?> get props => [];
}

// Charger toutes les saves pour un jeu
class LoadSavesEvent extends SavesEvent {
  final String gameId;

  const LoadSavesEvent(this.gameId);

  @override
  List<Object?> get props => [gameId];
}

// Sélectionner une save
class SelectSaveEvent extends SavesEvent {
  final int saveId;

  const SelectSaveEvent(this.saveId);

  @override
  List<Object?> get props => [saveId];
}
