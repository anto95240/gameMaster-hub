import 'package:gamemaster_hub/domain/domain_export.dart';

class InstructionDefenseSmModel extends InstructionDefenseSm {
  InstructionDefenseSmModel({
    required super.id,
    required super.tactiqueId,
    required super.saveId,
    super.pressing,
    super.styleTacle,
    super.ligneDefensive,
    super.gardienLibero,
    super.perteTemps,
  });

  factory InstructionDefenseSmModel.fromMap(Map<String, dynamic> map) {
    return InstructionDefenseSmModel(
      id: map['id'],
      tactiqueId: map['tactique_id'],
      saveId: map['save_id'],
      pressing: map['pressing'],
      styleTacle: map['style_tacle'],
      ligneDefensive: map['ligne_defensive'],
      gardienLibero: map['gardien_libero'],
      perteTemps: map['perte_temps'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tactique_id': tactiqueId,
      'save_id': saveId,
      'pressing': pressing,
      'style_tacle': styleTacle,
      'ligne_defensive': ligneDefensive,
      'gardien_libero': gardienLibero,
      'perte_temps': perteTemps,
    };
  }
}
