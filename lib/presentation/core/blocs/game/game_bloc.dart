import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/domain/core/repositories/game_repository.dart';

abstract class GameEvent {}
class LoadGames extends GameEvent {}

abstract class GameState {}
class GamesLoading extends GameState {}
class GamesLoaded extends GameState {
  final List<Game> games;
  GamesLoaded(this.games);
}
class GamesError extends GameState {
  final String message;
  GamesError(this.message);
}

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository repository;

  GameBloc(this.repository) : super(GamesLoading()) {
    on<LoadGames>((event, emit) async {
      emit(GamesLoading());
      try {
        final games = await repository.getAllGames();
        emit(GamesLoaded(games));

      } catch (e) {
        emit(GamesError(e.toString()));
      }
    });
  }
}
