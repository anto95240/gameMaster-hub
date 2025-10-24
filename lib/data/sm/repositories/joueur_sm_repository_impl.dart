import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class JoueurSmRepositoryImpl implements JoueurSmRepository {
  final JoueurSmRemoteDataSource remoteDataSource;

  JoueurSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<JoueurSm>> getAllJoueurs(int saveId) async {
    final models = await remoteDataSource.fetchJoueurs(saveId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<JoueurSm> getJoueurById(int id, int saveId) async {
    final models = await remoteDataSource.fetchJoueurs(saveId);
    final model = models.firstWhere(
      (j) => j.id == id,
      orElse: () => JoueurSmModel(
        id: -1,
        saveId: saveId,
        nom: 'Inconnu',
        age: 0,
        postes: [PosteEnum.GK],
        niveauActuel: 0,
        potentiel: 0,
        montantTransfert: 0,
        status: StatusEnum.Titulaire,
        dureeContrat: 0,
        salaire: 0,
        userId: '0',
      ),
    );
    return model.toEntity();
  }

  @override
  Future<void> insertJoueur(JoueurSm joueur) async {
    await remoteDataSource.insertJoueur(JoueurSmModel.fromEntity(joueur));
  }

  @override
  Future<void> updateJoueur(JoueurSm joueur) async {
    await remoteDataSource.updateJoueur(JoueurSmModel.fromEntity(joueur));
  }

  @override
  Future<void> deleteJoueur(int id) async {
    await remoteDataSource.deleteJoueur(id);
  }
}
