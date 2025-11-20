class TactiqueUserSm {
  final int id;
  final String formation;
  final int? modeleId;
  final String? nom;
  final String userId;
  final int saveId;

  TactiqueUserSm({
    required this.id,
    required this.formation,
    this.modeleId,
    this.nom,
    required this.userId,
    required this.saveId,
  });
}