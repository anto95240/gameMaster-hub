import 'package:gamemaster_hub/domain/domain_export.dart';

class TactiqueJoueurSmModel extends TactiqueJoueurSm {
  TactiqueJoueurSmModel({
    required super.id,
    required super.tactiqueId,
    required super.joueurId,
    required super.saveId,
    super.roleId,
  });

  factory TactiqueJoueurSmModel.fromMap(Map<String, dynamic> map) {
    return TactiqueJoueurSmModel(
      id: map['id'],
      tactiqueId: map['tactique_id'],
      joueurId: map['joueur_id'],
      saveId: map['save_id'],
      roleId: map['role_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tactique_id': tactiqueId,
      'joueur_id': joueurId,
      'save_id': saveId,
      'role_id': roleId,
    };
  }
}
