class RoleModeleSm {
  final int id;
  final String poste;
  final String role;
  final String? description;

  RoleModeleSm({
    required this.id,
    required this.poste,
    required this.role,
    this.description,
  });
}
