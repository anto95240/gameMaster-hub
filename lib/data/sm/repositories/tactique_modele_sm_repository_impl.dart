import 'package:gamemaster_hub/data/sm/datasources/tactique_modele_sm_remote_data_source.dart';
import 'package:gamemaster_hub/data/sm/models/tactique_modele_sm_model.dart';
import 'package:gamemaster_hub/domain/sm/entities/tactique_modele_sm.dart';
import 'package:gamemaster_hub/domain/sm/repositories/tactique_modele_sm_repository.dart';

class TactiqueModeleSmRepositoryImpl implements TactiqueModeleSmRepository {
  final TactiqueModeleSmRemoteDataSource remoteDataSource;

  TactiqueModeleSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TactiqueModeleSm>> getAllTactiques(int saveId) async {
    return await remoteDataSource.fetchTactiques(saveId);
  }

  @override
  Future<TactiqueModeleSmModel> getTactiqueById(int id, int saveId) async {
    final tactiques = await remoteDataSource.fetchTactiques(saveId);
    return tactiques.firstWhere(
      (t) => t.id == id,
      orElse: () => TactiqueModeleSmModel(
        id: -1,
        saveId: saveId,
        formation: '',
        mentalite: ''
      ),
    );
  }


  @override
  Future<void> insertTactique(TactiqueModeleSm tactique) async {
    await remoteDataSource.insertTactique(tactique as TactiqueModeleSmModel);
  }

  @override
  Future<void> updateTactique(TactiqueModeleSm tactique) async {
    await remoteDataSource.updateTactique(tactique as TactiqueModeleSmModel);
  }

  @override
  Future<void> deleteTactique(int id) async {
    await remoteDataSource.deleteTactique(id);
  }
}
