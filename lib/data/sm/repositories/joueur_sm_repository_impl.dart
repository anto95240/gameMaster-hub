import 'package:gamemaster_hub/domain/common/enums.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';
import 'package:gamemaster_hub/domain/sm/repositories/joueur_sm_repository.dart';
import '../datasources/joueur_sm_remote_data_source.dart';
import '../models/joueur_sm_model.dart';

class JoueurSmRepositoryImpl implements JoueurSmRepository {
  final JoueurSmRemoteDataSource remoteDataSource;

  JoueurSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<JoueurSm>> getAllJoueurs() async {
    final models = await remoteDataSource.fetchJoueurs();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<JoueurSm> getJoueurById(int id) async {
    final models = await remoteDataSource.fetchJoueurs();
    final model = models.firstWhere(
      (j) => j.id == id,
      orElse: () => JoueurSmModel(
        id: -1,
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
