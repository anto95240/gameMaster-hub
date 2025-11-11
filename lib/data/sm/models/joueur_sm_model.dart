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

    // ✅✅✅ CORRECTION PRINCIPALE : Utilisation de snake_case pour la lecture ✅✅✅
    return JoueurSmModel(
      id: map['id'] ?? 0,
      saveId: map['save_id'] ?? 0, // Corrigé
      nom: map['nom'] ?? 'Sans Nom',
      age: map['age'] ?? 0,
      postes: postes, // Utilise la liste sécurisée
      niveauActuel: map['niveau_actuel'] ?? 0, // Corrigé
      potentiel: map['potentiel'] ?? 0,
      montantTransfert: map['montant_transfert'] ?? 0, // Corrigé
      status: status, // Utilise le status sécurisé
      dureeContrat: map['duree_contrat'] ?? 0, // Corrigé
      salaire: map['salaire'] ?? 0,
      userId: map['user_id'] ?? '', // Corrigé
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'save_id': saveId, // Note : Assurez-vous que toMap utilise aussi snake_case
      'nom': nom,
      'age': age,
      'postes': postes.map((e) => e.name).toList(),
      'niveau_actuel': niveauActuel,
      'potentiel': potentiel,
      'montant_transfert': montantTransfert,
      'status': status.name,
      'duree_contrat': dureeContrat,
      'salaire': salaire,
      'user_id': userId,
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