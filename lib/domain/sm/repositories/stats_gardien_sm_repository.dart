import '../entities/stats_gardien_sm.dart';

abstract class StatsGardienSmRepository {
  Future<StatsGardienSm?> getStatsByJoueurId(int joueurId, int saveId);
  Future<void> insertStats(StatsGardienSm stats); // ✅ ajouté
  Future<void> updateStats(StatsGardienSm stats);
}
