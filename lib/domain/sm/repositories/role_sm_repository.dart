import 'package:gamemaster_hub/domain/sm/entities/role_modele_sm.dart';

abstract class RoleModeleSmRepository {
  Future<List<RoleModeleSm>> getAllRoles(int saveId);
  Future<RoleModeleSm?> getRoleByPoste(String poste, int saveId);
  Future<void> insertRole(RoleModeleSm role);
  Future<void> updateRole(RoleModeleSm role);
  Future<void> deleteRole(int id);
}
