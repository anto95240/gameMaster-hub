class StatsJoueurSm {
  final int id;
  final int joueurId;
  final int saveId;
  final int marquage;
  final int deplacement;
  final int frappesLointaines;
  final int passesLongues;
  final int coupsFrancs;
  final int tacles;
  final int finition;
  final int centres;
  final int passes;
  final int corners;
  final int positionnement;
  final int dribble;
  final int controle;
  final int penalties;
  final int creativite;
  final int stabiliteAerienne;
  final int vitesse;
  final int endurance;
  final int force;
  final int distanceParcourue;
  final int agressivite;
  final int sangFroid;
  final int concentration;
  final int flair;
  final int leadership;

  StatsJoueurSm({
    required this.id,
    required this.saveId,
    required this.joueurId,
    required this.marquage,
    required this.deplacement,
    required this.frappesLointaines,
    required this.passesLongues,
    required this.coupsFrancs,
    required this.tacles,
    required this.finition,
    required this.centres,
    required this.passes,
    required this.corners,
    required this.positionnement,
    required this.dribble,
    required this.controle,
    required this.penalties,
    required this.creativite,
    required this.stabiliteAerienne,
    required this.vitesse,
    required this.endurance,
    required this.force,
    required this.distanceParcourue,
    required this.agressivite,
    required this.sangFroid,
    required this.concentration,
    required this.flair,
    required this.leadership,
  });

  StatsJoueurSm copyWith({
    int? id,
    int? joueurId,
    int? saveId,
    int? marquage,
    int? deplacement,
    int? frappesLointaines,
    int? passesLongues,
    int? coupsFrancs,
    int? tacles,
    int? finition,
    int? centres,
    int? passes,
    int? corners,
    int? positionnement,
    int? dribble,
    int? controle,
    int? penalties,
    int? creativite,
    int? stabiliteAerienne,
    int? vitesse,
    int? endurance,
    int? force,
    int? distanceParcourue,
    int? agressivite,
    int? sangFroid,
    int? concentration,
    int? flair,
    int? leadership,
  }) {
    return StatsJoueurSm(
      id: id ?? this.id,
      joueurId: joueurId ?? this.joueurId,
      saveId: saveId ?? this.saveId,
      marquage: marquage ?? this.marquage,
      deplacement: deplacement ?? this.deplacement,
      frappesLointaines: frappesLointaines ?? this.frappesLointaines,
      passesLongues: passesLongues ?? this.passesLongues,
      coupsFrancs: coupsFrancs ?? this.coupsFrancs,
      tacles: tacles ?? this.tacles,
      finition: finition ?? this.finition,
      centres: centres ?? this.centres,
      passes: passes ?? this.passes,
      corners: corners ?? this.corners,
      positionnement: positionnement ?? this.positionnement,
      dribble: dribble ?? this.dribble,
      controle: controle ?? this.controle,
      penalties: penalties ?? this.penalties,
      creativite: creativite ?? this.creativite,
      stabiliteAerienne: stabiliteAerienne ?? this.stabiliteAerienne,
      vitesse: vitesse ?? this.vitesse,
      endurance: endurance ?? this.endurance,
      force: force ?? this.force,
      distanceParcourue: distanceParcourue ?? this.distanceParcourue,
      agressivite: agressivite ?? this.agressivite,
      sangFroid: sangFroid ?? this.sangFroid,
      concentration: concentration ?? this.concentration,
      flair: flair ?? this.flair,
      leadership: leadership ?? this.leadership,
    );
  }
}
