class RoleModeleSm {
  final int id;
  final int saveId;
  final String poste;
  final String role;
  final String? description;

  RoleModeleSm({
    required this.id,
    required this.saveId,
    required this.poste,
    required this.role,
    this.description,
  });
}
