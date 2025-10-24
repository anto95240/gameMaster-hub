import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class StatsGardienSmRepositoryImpl implements StatsGardienSmRepository {
  final StatsGardienSmRemoteDataSource remoteDataSource;
  StatsGardienSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<StatsGardienSm>> getAllStats(int saveId) async {
    final models = await remoteDataSource.fetchStats(saveId);
    return models;
  }

  @override
  Future<StatsGardienSm?> getStatsByJoueurId(int joueurId, int saveId) async {
    final model = await remoteDataSource.fetchStatsGardien(joueurId, saveId);
    return model;
  }

  @override
  Future<void> insertStats(StatsGardienSm stats) async {
    final model = StatsGardienSmModel(
      id: stats.id,
      joueurId: stats.joueurId,
      saveId: stats.saveId,
      autoriteSurface: stats.autoriteSurface,
      distribution: stats.distribution,
      captation: stats.captation,
      duels: stats.duels,
      arrets: stats.arrets,
      positionnement: stats.positionnement,
      penalties: stats.penalties,
      stabiliteAerienne: stats.stabiliteAerienne,
      vitesse: stats.vitesse,
      force: stats.force,
      agressivite: stats.agressivite,
      sangFroid: stats.sangFroid,
      concentration: stats.concentration,
      leadership: stats.leadership,
    );
    await remoteDataSource.insertStatsGardien(model);
  }

  @override
  Future<void> updateStats(StatsGardienSm stats) async {
    final model = StatsGardienSmModel(
      id: stats.id,
      joueurId: stats.joueurId,
      saveId: stats.saveId,
      autoriteSurface: stats.autoriteSurface,
      distribution: stats.distribution,
      captation: stats.captation,
      duels: stats.duels,
      arrets: stats.arrets,
      positionnement: stats.positionnement,
      penalties: stats.penalties,
      stabiliteAerienne: stats.stabiliteAerienne,
      vitesse: stats.vitesse,
      force: stats.force,
      agressivite: stats.agressivite,
      sangFroid: stats.sangFroid,
      concentration: stats.concentration,
      leadership: stats.leadership,
    );
    await remoteDataSource.updateStatsGardien(model);
  }

  @override
  Future<void> deleteStats(int id) async {
    await remoteDataSource.deleteStats(id);
  }
}
