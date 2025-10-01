import '../entities/role_modele_sm.dart';

abstract class RoleModeleSmRepository {
  Future<List<RoleModeleSm>> getAllRoles();
  Future<RoleModeleSm?> getRoleByPoste(String poste);
  Future<void> insertRole(RoleModeleSm role);
  Future<void> updateRole(RoleModeleSm role);
  Future<void> deleteRole(int id);
}
