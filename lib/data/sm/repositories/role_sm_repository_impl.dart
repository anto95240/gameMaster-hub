import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class RoleModeleSmRepositoryImpl implements RoleModeleSmRepository {
  final RoleModeleSmRemoteDataSource remoteDataSource;

  RoleModeleSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RoleModeleSm>> getAllRoles(int saveId) async {
    return await remoteDataSource.fetchRoles(saveId);
  }

  @override
  Future<RoleModeleSmModel> getRoleByPoste(String poste, int saveId) async {
    final roles = await remoteDataSource.fetchRoles(saveId);
    return roles.firstWhere(
      (r) => r.poste == poste,
      orElse: () => RoleModeleSmModel(
        id: -1,
        saveId: saveId,
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
