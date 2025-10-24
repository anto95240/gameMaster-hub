import 'package:equatable/equatable.dart';

class StatsGardienSm extends Equatable {
  final int id;
  final int joueurId;
  final int saveId; // ✅ ajouté
  final int autoriteSurface;
  final int distribution;
  final int captation;
  final int duels;
  final int arrets;
  final int positionnement;
  final int penalties;
  final int stabiliteAerienne;
  final int vitesse;
  final int force;
  final int agressivite;
  final int sangFroid;
  final int concentration;
  final int leadership;

  const StatsGardienSm({
    required this.id,
    required this.joueurId,
    required this.saveId, // ✅ ajouté
    this.autoriteSurface = 0,
    this.distribution = 0,
    this.captation = 0,
    this.duels = 0,
    this.arrets = 0,
    this.positionnement = 0,
    this.penalties = 0,
    this.stabiliteAerienne = 0,
    this.vitesse = 0,
    this.force = 0,
    this.agressivite = 0,
    this.sangFroid = 0,
    this.concentration = 0,
    this.leadership = 0,
  });

  StatsGardienSm copyWith({
    int? id,
    int? joueurId,
    int? saveId,
    int? autoriteSurface,
    int? distribution,
    int? captation,
    int? duels,
    int? arrets,
    int? positionnement,
    int? penalties,
    int? stabiliteAerienne,
    int? vitesse,
    int? force,
    int? agressivite,
    int? sangFroid,
    int? concentration,
    int? leadership,
  }) {
    return StatsGardienSm(
      id: id ?? this.id,
      joueurId: joueurId ?? this.joueurId,
      saveId: saveId ?? this.saveId,
      autoriteSurface: autoriteSurface ?? this.autoriteSurface,
      distribution: distribution ?? this.distribution,
      captation: captation ?? this.captation,
      duels: duels ?? this.duels,
      arrets: arrets ?? this.arrets,
      positionnement: positionnement ?? this.positionnement,
      penalties: penalties ?? this.penalties,
      stabiliteAerienne: stabiliteAerienne ?? this.stabiliteAerienne,
      vitesse: vitesse ?? this.vitesse,
      force: force ?? this.force,
      agressivite: agressivite ?? this.agressivite,
      sangFroid: sangFroid ?? this.sangFroid,
      concentration: concentration ?? this.concentration,
      leadership: leadership ?? this.leadership,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'joueur_id': joueurId,
        'save_id': saveId,
        'autorite_surface': autoriteSurface,
        'distribution': distribution,
        'captation': captation,
        'duels': duels,
        'arrets': arrets,
        'positionnement': positionnement,
        'penalties': penalties,
        'stabilite_aerienne': stabiliteAerienne,
        'vitesse': vitesse,
        'force': force,
        'agressivite': agressivite,
        'sang_froid': sangFroid,
        'concentration': concentration,
        'leadership': leadership,
      };

  @override
  List<Object?> get props => [id, joueurId, saveId];
}
