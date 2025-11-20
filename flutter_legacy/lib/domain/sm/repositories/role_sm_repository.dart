import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class RoleModeleSmRepository {
  Future<List<RoleModeleSm>> getAllRoles();
  Future<RoleModeleSm?> getRoleByPoste(String poste);
  Future<void> insertRole(RoleModeleSm role);
  Future<void> updateRole(RoleModeleSm role);
  Future<void> deleteRole(int id);
}
