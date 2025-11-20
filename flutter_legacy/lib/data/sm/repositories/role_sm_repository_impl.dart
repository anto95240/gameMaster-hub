import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class RoleModeleSmRepositoryImpl implements RoleModeleSmRepository {
  final RoleModeleSmRemoteDataSource remoteDataSource;

  RoleModeleSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RoleModeleSm>> getAllRoles() async {
    return await remoteDataSource.fetchRoles();
  }

  @override
  Future<RoleModeleSmModel> getRoleByPoste(String poste) async {
    final roles = await remoteDataSource.fetchRoles();
    return roles.firstWhere(
      (r) => r.poste == poste,
      orElse: () => RoleModeleSmModel(
        id: -1,
        poste: poste,
        role: '',
        description: '',
      ),
    );
  }

  @override
  Future<void> insertRole(RoleModeleSm role) async {
    await remoteDataSource.insertRole(role as RoleModeleSmModel);
  }

  @override
  Future<void> updateRole(RoleModeleSm role) async {
    await remoteDataSource.updateRole(role as RoleModeleSmModel);
  }

  @override
  Future<void> deleteRole(int id) async {
    await remoteDataSource.deleteRole(id);
  }
}
