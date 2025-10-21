// domain/core/repositories/game_repository.dart
import 'package:gamemaster_hub/domain/core/entities/game.dart';

abstract class GameRepository {
  Future<List<Game>> getAllGames();
  Future<Game?> getGameById(int id);

  Future<List<Game>> getAllGamesWithSaves();
  Future<Game?> getGameByIdWithSaves(int id);
}
