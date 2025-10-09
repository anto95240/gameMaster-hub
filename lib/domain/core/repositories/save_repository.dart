import '../entities/save.dart';

abstract class SaveRepository {
  Future<List<Save>> getSavesByGame(String gameId);
  Future<Save?> getSaveById(int saveId);
  Future<int> createSave(Save save);
  Future<void> updateSave(Save save);
  Future<void> deleteSave(int saveId);
}
