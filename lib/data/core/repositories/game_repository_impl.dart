import '../../../domain/core/entities/game.dart';
import '../../../domain/core/repositories/game_repository.dart';
import '../datasourses/game_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  final GameDatasource datasource;

  GameRepositoryImpl(this.datasource);

  @override
  Future<List<Game>> getGames() => datasource.getGames();

  @override
  Future<Game?> getGameById(String id) => datasource.getGameById(id);
}
