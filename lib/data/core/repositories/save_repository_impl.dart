import 'package:gamemaster_hub/data/core/models/save_model.dart';

import '../../../domain/core/entities/save.dart';
import '../../../domain/core/repositories/save_repository.dart';
import '../datasourses/save_datasource.dart';

class SaveRepositoryImpl implements SaveRepository {
  final SaveDatasource datasource;

  SaveRepositoryImpl(this.datasource);

  @override
  Future<List<Save>> getSavesByGame(String gameId) =>
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
