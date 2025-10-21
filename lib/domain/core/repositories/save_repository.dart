import 'package:gamemaster_hub/domain/core/entities/save.dart';

abstract class SaveRepository {
  Future<List<Save>> getSavesByGame(int gameId);
  Future<Save?> getSaveById(int saveId);
  Future<int> createSave(Save save);
  Future<void> updateSave(Save save);
  Future<void> deleteSave(int saveId);

  Future<int> countPlayersBySave(int saveId);
  Future<double> averageRatingBySave(int saveId);
}
