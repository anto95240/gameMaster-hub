import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class TactiqueUserSmRepositoryImpl implements TactiqueUserSmRepository {
  final TactiqueUserSmRemoteDataSource remoteDataSource;

  TactiqueUserSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TactiqueUserSm>> getAll(int saveId) async {
    return await remoteDataSource.fetchAll(saveId);
  }

  @override
  Future<TactiqueUserSm?> getLatest(int saveId) async {
    return await remoteDataSource.fetchLatest(saveId);
  }

  @override
  Future<int> insert(TactiqueUserSm tactique) async {
    return await remoteDataSource.insert(tactique as TactiqueUserSmModel);
  }

  @override
  Future<void> update(TactiqueUserSm tactique) async {
    await remoteDataSource.update(tactique as TactiqueUserSmModel);
  }

  @override
  Future<void> delete(int id) async {
    await remoteDataSource.delete(id);
  }
}


