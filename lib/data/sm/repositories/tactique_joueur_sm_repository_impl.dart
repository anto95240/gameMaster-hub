import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class TactiqueJoueurSmRepositoryImpl implements TactiqueJoueurSmRepository {
  final TactiqueJoueurSmRemoteDataSource remoteDataSource;

  TactiqueJoueurSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TactiqueJoueurSm>> getAll(int saveId) async {
    return await remoteDataSource.fetchAll(saveId);
  }

  @override
  Future<List<TactiqueJoueurSm>> getByTactiqueId(int tactiqueId, int saveId) async {
    final list = await remoteDataSource.fetchAll(saveId);
    return list.where((tj) => tj.tactiqueId == tactiqueId).toList();
  }

  @override
  Future<void> insert(TactiqueJoueurSm tj) async {
    await remoteDataSource.insert(tj as TactiqueJoueurSmModel);
  }

  @override
  Future<void> update(TactiqueJoueurSm tj) async {
    await remoteDataSource.update(tj as TactiqueJoueurSmModel);
  }

  @override
  Future<void> delete(int id) async {
    await remoteDataSource.delete(id);
  }
}
