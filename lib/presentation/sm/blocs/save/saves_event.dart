// lib/presentation/sm/blocs/save/saves_event.dart
import 'package:equatable/equatable.dart';

abstract class SavesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSavesEvent extends SavesEvent {
  final int gameId;
  LoadSavesEvent(this.gameId);

  @override
  List<Object?> get props => [gameId];
}
