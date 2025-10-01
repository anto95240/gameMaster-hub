import '../entities/stats_joueur_sm.dart';

abstract class StatsJoueurSmRepository {
  Future<List<StatsJoueurSm>> getAllStats();
  Future<StatsJoueurSm?> getStatsByJoueurId(int joueurId);
  Future<void> insertStats(StatsJoueurSm stats);
  Future<void> updateStats(StatsJoueurSm stats);
  Future<void> deleteStats(int id);
}
