import 'package:gamemaster_hub/domain/sm/entities/stats_gardien_sm.dart';

class StatsGardienSmModel extends StatsGardienSm {
  StatsGardienSmModel({
    required super.id,
    required super.joueurId,
    required super.saveId, // ✅ ajouté
    super.autoriteSurface,
    super.distribution,
    super.captation,
    super.duels,
    super.arrets,
    super.positionnement,
    super.penalties,
    super.stabiliteAerienne,
    super.vitesse,
    super.force,
    super.agressivite,
    super.sangFroid,
    super.concentration,
    super.leadership,
  });

  factory StatsGardienSmModel.fromMap(Map<String, dynamic> map) {
    return StatsGardienSmModel(
      id: map['id'],
      joueurId: map['joueur_id'],
      saveId: map['save_id'], // ✅ ajouté
      autoriteSurface: map['autorite_surface'] ?? 0,
      distribution: map['distribution'] ?? 0,
      captation: map['captation'] ?? 0,
      duels: map['duels'] ?? 0,
      arrets: map['arrets'] ?? 0,
      positionnement: map['positionnement'] ?? 0,
      penalties: map['penalties'] ?? 0,
      stabiliteAerienne: map['stabilite_aerienne'] ?? 0,
      vitesse: map['vitesse'] ?? 0,
      force: map['force'] ?? 0,
      agressivite: map['agressivite'] ?? 0,
      sangFroid: map['sang_froid'] ?? 0,
      concentration: map['concentration'] ?? 0,
      leadership: map['leadership'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
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
}
