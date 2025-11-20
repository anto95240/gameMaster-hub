import 'package:gamemaster_hub/domain/domain_export.dart';

class InstructionAttaqueSmModel extends InstructionAttaqueSm {
  InstructionAttaqueSmModel({
    required super.id,
    required super.tactiqueId,
    required super.saveId,
    super.userId,
    super.stylePasse,
    super.styleAttaque,
    super.attaquants,
    super.jeuLarge,
    super.jeuConstruction,
    super.contreAttaque,
  });

  factory InstructionAttaqueSmModel.fromMap(Map<String, dynamic> map) {
    return InstructionAttaqueSmModel(
      id: map['id'],
      tactiqueId: map['tactique_id'],
      saveId: map['save_id'],
      userId: map['user_id'],
      stylePasse: map['style_passe'],
      styleAttaque: map['style_attaque'],
      attaquants: map['attaquants'],
      jeuLarge: map['jeu_large'],
      jeuConstruction: map['jeu_construction'],
      contreAttaque: map['contre_attaque'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tactique_id': tactiqueId,
      'save_id': saveId,
      'user_id': userId,
      'style_passe': stylePasse,
      'style_attaque': styleAttaque,
      'attaquants': attaquants,
      'jeu_large': jeuLarge,
      'jeu_construction': jeuConstruction,
      'contre_attaque': contreAttaque,
    };
  }
}
