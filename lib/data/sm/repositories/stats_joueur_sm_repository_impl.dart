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
  Future<StatsJoueurSmModel> getStatsByJoueurId(int joueurId, int saveId) async {
    final statsList = await remoteDataSource.fetchStats(saveId);
    return statsList.firstWhere(
      (s) => s.joueurId == joueurId,
      orElse: () => StatsJoueurSmModel(
        id: -1,
        joueurId: joueurId,
        saveId: saveId,
        marquage: 0,
        deplacement: 0,
        frappesLointaines: 0,
        passesLongues: 0,
        coupsFrancs: 0,
        tacles: 0,
        finition: 0,
        centres: 0,
        passes: 0,
        corners: 0,
        positionnement: 0,
        dribble: 0,
        controle: 0,
        penalties: 0,
        creativite: 0,
        stabiliteAerienne: 0,
        vitesse: 0,
        endurance: 0,
        force: 0,
        distanceParcourue: 0,
        agressivite: 0,
        sangFroid: 0,
        concentration: 0,
        flair: 0,
        leadership: 0
      ),
    );
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
