import 'package:gamemaster_hub/domain/sm/entities/instruction_general_sm.dart';

class InstructionGeneralSmModel extends InstructionGeneralSm {
  InstructionGeneralSmModel({
    required super.id,
    required super.tactiqueId,
    required super.saveId,
    super.largeur,
    super.mentalite,
    super.tempo,
    super.fluidite,
    super.rythmeTravail,
    super.creativite,
  });

  factory InstructionGeneralSmModel.fromMap(Map<String, dynamic> map) {
    return InstructionGeneralSmModel(
      id: map['id'],
      tactiqueId: map['tactique_id'],
      saveId: map['save_id'],
      largeur: map['largeur'],
      mentalite: map['mentalite'],
      tempo: map['tempo'],
      fluidite: map['fluidite'],
      rythmeTravail: map['rythme_travail'],
      creativite: map['creativite'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tactique_id': tactiqueId,
      'save_id': saveId,
      'largeur': largeur,
      'mentalite': mentalite,
      'tempo': tempo,
      'fluidite': fluidite,
      'rythme_travail': rythmeTravail,
      'creativite': creativite,
    };
  }
}
