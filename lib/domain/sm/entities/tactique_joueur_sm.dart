class TactiqueJoueurSm {
  final int id;
  final int tactiqueId;
  final int joueurId;
  final int? roleId;

  TactiqueJoueurSm({
    required this.id,
    required this.tactiqueId,
    required this.joueurId,
    this.roleId,
  });
}
