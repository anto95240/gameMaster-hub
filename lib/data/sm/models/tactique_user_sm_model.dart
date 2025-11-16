import 'package:gamemaster_hub/domain/domain_export.dart';

class TactiqueUserSmModel extends TactiqueUserSm {
  TactiqueUserSmModel({
    required super.id,
    required super.formation,
    super.modeleId,
    super.nom,
    required super.userId,
    required super.saveId,
  });

  factory TactiqueUserSmModel.fromMap(Map<String, dynamic> map) {
    return TactiqueUserSmModel(
      id: map['id'],
      formation: map['formation'],
      modeleId: map['modele_id'],
      nom: map['nom'],
      userId: map['user_id'],
      saveId: map['save_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'formation': formation,
      'modele_id': modeleId,
      'nom': nom,
      'user_id': userId,
      'save_id': saveId,
    };
  }
}


