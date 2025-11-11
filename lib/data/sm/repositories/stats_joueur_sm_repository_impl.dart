import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class StatsJoueurSmRepositoryImpl implements StatsJoueurSmRepository {
  final StatsJoueurSmRemoteDataSource remoteDataSource;

  StatsJoueurSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<StatsJoueurSm>> getAllStats(int saveId) async {
    return await remoteDataSource.fetchStats(saveId);
  }

  @override
  // Changé pour retourner un type nullable
  Future<StatsJoueurSm?> getStatsByJoueurId(int joueurId, int saveId) async {
    final statsList = await remoteDataSource.fetchStats(saveId);

    // Utilise .where et .firstOrNull (ou une vérification .isEmpty)
    final stats = statsList.where((s) => s.joueurId == joueurId);

    if (stats.isEmpty) {
      return null; // Retourne null si rien n'est trouvé
    } else {
      return stats.first; // Retourne le premier (et unique) stat
    }
  }

  @override
  Future<void> insertStats(StatsJoueurSm stats) async {
    await remoteDataSource.insertStats(stats as StatsJoueurSmModel);
  }

  @override
  Future<void> updateStats(StatsJoueurSm stats) async {
    await remoteDataSource.updateStats(stats as StatsJoueurSmModel);
  }

  @override
  Future<void> deleteStats(int id) async {
    await remoteDataSource.deleteStats(id);
  }
}