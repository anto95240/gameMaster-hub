import 'package:gamemaster_hub/domain/domain_export.dart';

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

  factory JoueurSmModel.fromMap(Map<String, dynamic> map) {
    // --- Correction pour les Postes ---
    final postesList = map['postes'] as List<dynamic>?;
    final List<PosteEnum> postes;
    if (postesList == null || postesList.isEmpty) {
      postes = [PosteEnum.G]; // Valeur par défaut si c'est vide ou null
    } else {
      postes = postesList
          .map((e) {
            try {
              // Tente de trouver le poste
              return PosteEnum.values.firstWhere((p) => p.name == e);
            } catch (err) {
              // Si échec, retourne un poste par défaut (ex: G)
              return PosteEnum.G; 
            }
          })
          .toList();
    }

    // --- Correction pour le Status ---
    final statusString = map['status'] as String?;
    
    // ✅✅✅ LA CORRECTION EST ICI ✅✅✅
    // On retire le 'final' pour permettre l'assignation ci-dessous.
    StatusEnum status; 
    
    if (statusString == null) {
      status = StatusEnum.Remplacant; // Valeur par défaut
    } else {
      try {
        status = StatusEnum.values.firstWhere((e) => e.name == statusString);
      } catch (e) {
        status = StatusEnum.Remplacant; // Valeur par défaut si inconnu
      }
    }

    return JoueurSmModel(
      id: map['id'] ?? 0,
      saveId: map['saveId'] ?? 0,
      nom: map['nom'] ?? 'Sans Nom',
      age: map['age'] ?? 0,
      postes: postes, // Utilise la liste sécurisée
      niveauActuel: map['niveauActuel'] ?? 0,
      potentiel: map['potentiel'] ?? 0,
      montantTransfert: map['montantTransfert'] ?? 0,
      status: status, // Utilise le status sécurisé
      dureeContrat: map['dureeContrat'] ?? 0,
      salaire: map['salaire'] ?? 0,
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saveId': saveId,
      'nom': nom,
      'age': age,
      'postes': postes.map((e) => e.name).toList(),
      'niveauActuel': niveauActuel,
      'potentiel': potentiel,
      'montantTransfert': montantTransfert,
      'status': status.name,
      'dureeContrat': dureeContrat,
      'salaire': salaire,
      'userId': userId,
    };
  }

  JoueurSm toEntity() {
    return JoueurSm(
      id: id,
      saveId: saveId,
      nom: nom,
      age: age,
      postes: postes,
      niveauActuel: niveauActuel,
      potentiel: potentiel,
      montantTransfert: montantTransfert,
      status: status,
      dureeContrat: dureeContrat,
      salaire: salaire,
      userId: userId,
    );
  }

  factory JoueurSmModel.fromEntity(JoueurSm entity) {
    return JoueurSmModel(
      id: entity.id,
      saveId: entity.saveId,
      nom: entity.nom,
      age: entity.age,
      postes: entity.postes,
      niveauActuel: entity.niveauActuel,
      potentiel: entity.potentiel,
      montantTransfert: entity.montantTransfert,
      status: entity.status,
      dureeContrat: entity.dureeContrat,
      salaire: entity.salaire,
      userId: entity.userId,
    );
  }
}