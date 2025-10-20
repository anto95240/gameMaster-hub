import 'package:gamemaster_hub/data/core/datasourses/save_datasource.dart';
import '../models/save_model.dart';
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
      id: 0, // Supabase générera l'id
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
  Future<void> updateSave(Save save) => datasource.updateSave(SaveModel(
        id: save.id,
        gameId: save.gameId,
        userId: save.userId,
        name: save.name,
        description: save.description,
        isActive: save.isActive,
        numberOfPlayers: save.numberOfPlayers,
        overallRating: save.overallRating,
      ));

  @override
  Future<void> deleteSave(int saveId) => datasource.deleteSave(saveId);

  @override
  Future<int> countPlayersBySave(int saveId) =>
      datasource.countPlayersBySave(saveId);

  @override
  Future<double> averageRatingBySave(int saveId) =>
      datasource.averageRatingBySave(saveId);
}
