import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class StatsGardienSmRepository {
  Future<List<StatsGardienSm>> getAllStats(int saveId);
  Future<StatsGardienSm?> getStatsByJoueurId(int joueurId, int saveId);
  Future<void> insertStats(StatsGardienSm stats);
  Future<void> updateStats(StatsGardienSm stats);
  Future<void> deleteStats(int id);
}
