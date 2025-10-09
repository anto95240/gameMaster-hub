class TactiqueModeleSm {
  final int id;
  final String formation;
  final int saveId;
  final String? mentalite;

  TactiqueModeleSm({
    required this.id,
    required this.formation,
    required this.saveId,
    this.mentalite,
  });
}
