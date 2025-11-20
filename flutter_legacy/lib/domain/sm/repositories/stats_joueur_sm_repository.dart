import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class StatsJoueurSmRepository {
  Future<List<StatsJoueurSm>> getAllStats(int saveId);
  Future<StatsJoueurSm?> getStatsByJoueurId(int joueurId, int saveId);
  Future<void> insertStats(StatsJoueurSm stats);
  Future<void> updateStats(StatsJoueurSm stats);
  Future<void> deleteStats(int id);
}
