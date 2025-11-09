class TactiqueJoueurSm {
  final int id;
  final int tactiqueId;
  final int joueurId;
  final int saveId;
  final int? roleId;
  final String? userId;

  TactiqueJoueurSm({
    required this.id,
    required this.tactiqueId,
    required this.joueurId,
    required this.saveId,
    this.roleId,
    this.userId,

  });
}
