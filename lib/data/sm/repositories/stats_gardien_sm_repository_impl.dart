import 'package:gamemaster_hub/data/sm/datasources/stats_gardien_sm_remote_data_source.dart';
import 'package:gamemaster_hub/data/sm/models/stats_gardien_sm_model.dart';
import 'package:gamemaster_hub/domain/sm/entities/stats_gardien_sm.dart';
import 'package:gamemaster_hub/domain/sm/repositories/stats_gardien_sm_repository.dart';

class StatsGardienSmRepositoryImpl implements StatsGardienSmRepository {
  final StatsGardienSmRemoteDataSource remoteDataSource;
  StatsGardienSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<StatsGardienSm?> getStatsByJoueurId(int joueurId, int saveId) async {
    final data = await remoteDataSource.fetchStatsGardien(joueurId, saveId);
    if (data == null) return null;
    return StatsGardienSmModel.fromMap(data);
  }

  @override
  Future<void> insertStats(StatsGardienSm stats) async {
    final model = StatsGardienSmModel(
      id: 0,
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

    await remoteDataSource.insertStatsGardien(model.toMap());
  }

  @override
  Future<void> updateStats(StatsGardienSm stats) async {
    await remoteDataSource.updateStatsGardien(stats.id, {
      'autorite_surface': stats.autoriteSurface,
      'distribution': stats.distribution,
      'captation': stats.captation,
      'duels': stats.duels,
      'arrets': stats.arrets,
      'positionnement': stats.positionnement,
      'penalties': stats.penalties,
      'stabilite_aerienne': stats.stabiliteAerienne,
      'vitesse': stats.vitesse,
      'force': stats.force,
      'agressivite': stats.agressivite,
      'sang_froid': stats.sangFroid,
      'concentration': stats.concentration,
      'leadership': stats.leadership,
    });
  }
}
