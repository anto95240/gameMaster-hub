import 'package:gamemaster_hub/domain/common/enums.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';

class JoueurSmModel extends JoueurSm {
  JoueurSmModel({
    required super.id,
    required super.saveId,
    required super.nom,
    required super.age,
    required super.postes,
    required super.niveauActuel,
    required super.potentiel,
    required super.montantTransfert,
    required super.status,
    required super.dureeContrat,
    required super.salaire,
    required super.userId,
  });

  JoueurSm toEntity() => this;

  factory JoueurSmModel.fromEntity(JoueurSm joueur) => JoueurSmModel(
        id: joueur.id,
        saveId: joueur.saveId,
        nom: joueur.nom,
        age: joueur.age,
        postes: joueur.postes,
        niveauActuel: joueur.niveauActuel,
        potentiel: joueur.potentiel,
        montantTransfert: joueur.montantTransfert,
        status: joueur.status,
        dureeContrat: joueur.dureeContrat,
        salaire: joueur.salaire,
        userId: joueur.userId,
      );

  factory JoueurSmModel.fromMap(Map<String, dynamic> map) {
    return JoueurSmModel(
      id: map['id'],
      saveId: map['save_id'],
      nom: map['nom'],
      age: map['age'],
      postes: (map['postes'] as List<dynamic>)
          .map((p) => PosteEnum.values.firstWhere((e) => e.name == p))
          .toList(),
      niveauActuel: map['niveau_actuel'],
      potentiel: map['potentiel'],
      montantTransfert: map['montant_transfert'],
      status: StatusEnum.values.firstWhere((e) => e.name == map['status']),
      dureeContrat: map['duree_contrat'],
      salaire: map['salaire'],
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'save_id': saveId,
    'nom': nom,
    'age': age,
    'postes': postes.map((p) => p.name).toList(),
    'niveau_actuel': niveauActuel,
    'potentiel': potentiel,
    'montant_transfert': montantTransfert,
    'status': status.name,
    'duree_contrat': dureeContrat,
    'salaire': salaire,
    'user_id': userId,
  };
}
