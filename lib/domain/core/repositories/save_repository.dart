// lib/domain/core/repositories/save_repository.dart
import '../entities/save.dart';

abstract class SaveRepository {
  Future<List<Save>> getSavesByGame(int gameId);
  Future<Save?> getSaveById(int saveId);
  Future<int> createSave(Save save);
  Future<void> updateSave(Save save);
  Future<void> deleteSave(int saveId);

  // Ajout pour nombre de joueurs et moyenne des notes
  Future<int> countPlayersBySave(int saveId);
  Future<double> averageRatingBySave(int saveId);
}
