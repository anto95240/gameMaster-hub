import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/role_sm_model.dart';

class RoleModeleSmRemoteDataSource {
  final SupabaseClient supabase;

  RoleModeleSmRemoteDataSource(this.supabase);

  Future<List<RoleModeleSmModel>> fetchRoles(int saveId) async {
    final response = await supabase
        .from('role_modele_sm')
        .select()
        .eq('save_id', saveId)
        .execute();
    final data = response.data as List<dynamic>;
    return data.map((e) => RoleModeleSmModel.fromMap(e)).toList();
  }

  Future<void> insertRole(RoleModeleSmModel role) async {
    await supabase.from('role_modele_sm').insert(role.toMap()).execute();
  }

  Future<void> updateRole(RoleModeleSmModel role) async {
    await supabase.from('role_modele_sm')
        .update(role.toMap())
        .eq('id', role.id)
        .execute();
  }

  Future<void> deleteRole(int id) async {
    await supabase.from('role_modele_sm').delete().eq('id', id).execute();
  }
}
