import 'package:gamemaster_hub/domain/domain_export.dart';

class TactiqueModeleSmModel extends TactiqueModeleSm {
  TactiqueModeleSmModel({
    required super.id,
    required super.saveId,
    required super.formation,
    super.mentalite,
  });

  factory TactiqueModeleSmModel.fromMap(Map<String, dynamic> map) {
    return TactiqueModeleSmModel(
      id: map['id'],
      saveId: map['save_id'],
      formation: map['formation'],
      mentalite: map['mentalite'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'save_id': saveId,
      'formation': formation,
      'mentalite': mentalite,
    };
  }
}
