// lib/data/core/repositories/save_repository_impl.dart
import 'package:gamemaster_hub/data/core/datasourses/save_datasource.dart';
import 'package:gamemaster_hub/data/core/models/save_model.dart';
import '../../../domain/core/entities/save.dart';
import '../../../domain/core/repositories/save_repository.dart';

class SaveRepositoryImpl implements SaveRepository {
  final SaveDatasource datasource;

  SaveRepositoryImpl(this.datasource);

  @override
  Future<List<Save>> getSavesByGame(int gameId) =>
      datasource.getSavesByGame(gameId);

  @override
  Future<Save?> getSaveById(int saveId) => datasource.getSaveById(saveId);

  @override
  Future<int> createSave(Save save) {
    final saveModel = SaveModel(
      id: save.id,
      gameId: save.gameId,
      userId: save.userId,
      name: save.name,
      description: save.description,
      isActive: save.isActive,
      numberOfPlayers: save.numberOfPlayers,
      overallRating: save.overallRating,
    );
    return datasource.createSave(saveModel);
  }

  @override
  Future<int> countPlayersBySave(int saveId) => datasource.countPlayersBySave(saveId);

  @override
  Future<double> averageRatingBySave(int saveId) => datasource.averageRatingBySave(saveId);

  @override
  Future<void> updateSave(Save save) {
    final saveModel = SaveModel(
      id: save.id,
      gameId: save.gameId,
      userId: save.userId,
      name: save.name,
      description: save.description,
      isActive: save.isActive,
      numberOfPlayers: save.numberOfPlayers,
      overallRating: save.overallRating,
    );
    return datasource.updateSave(saveModel);
  }

  @override
  Future<void> deleteSave(int saveId) => datasource.deleteSave(saveId);
}
