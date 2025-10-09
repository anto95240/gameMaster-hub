import '../entities/game.dart';

abstract class GameRepository {
  Future<List<Game>> getGames();
  Future<Game?> getGameById(String id);
}
