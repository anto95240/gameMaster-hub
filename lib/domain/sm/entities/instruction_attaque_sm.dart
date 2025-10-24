class InstructionAttaqueSm {
  final int id;
  final int tactiqueId;
  final int saveId;
  final String? stylePasse;
  final String? styleAttaque;
  final String? attaquants;
  final String? jeuLarge;
  final String? jeuConstruction;
  final String? contreAttaque;

  InstructionAttaqueSm({
    required this.id,
    required this.tactiqueId,
    required this.saveId,
    this.stylePasse,
    this.styleAttaque,
    this.attaquants,
    this.jeuLarge,
    this.jeuConstruction,
    this.contreAttaque,
  });
}
