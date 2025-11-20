import 'package:gamemaster_hub/domain/domain_export.dart';

class TactiqueModeleSmModel extends TactiqueModeleSm {
  TactiqueModeleSmModel({
    required super.id,
    required super.formation,
  });

  factory TactiqueModeleSmModel.fromMap(Map<String, dynamic> map) {
    return TactiqueModeleSmModel(
      id: map['id'],
      formation: map['formation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'formation': formation,
    };
  }
}
