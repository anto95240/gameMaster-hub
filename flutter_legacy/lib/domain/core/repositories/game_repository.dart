import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class GameRepository {
  Future<List<Game>> getAllGames();
  Future<Game?> getGameById(int id);

  Future<List<Game>> getAllGamesWithSaves();
  Future<Game?> getGameByIdWithSaves(int id);
}
