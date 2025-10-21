import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gamemaster_hub/data/sm/models/tactique_modele_sm_model.dart';

class TactiqueModeleSmRemoteDataSource {
  final SupabaseClient supabase;

  TactiqueModeleSmRemoteDataSource(this.supabase);

  Future<List<TactiqueModeleSmModel>> fetchTactiques(int saveId) async {
    final response = await supabase
        .from('tactique_modele_sm')
        .select()
        .eq('save_id', saveId)
        .execute();
    final data = response.data as List<dynamic>;
    return data.map((e) => TactiqueModeleSmModel.fromMap(e)).toList();
  }

  Future<void> insertTactique(TactiqueModeleSmModel tactique) async {
    await supabase.from('tactique_modele_sm').insert(tactique.toMap()).execute();
  }

  Future<void> updateTactique(TactiqueModeleSmModel tactique) async {
    await supabase.from('tactique_modele_sm')
        .update(tactique.toMap())
        .eq('id', tactique.id)
        .execute();
  }

  Future<void> deleteTactique(int id) async {
    await supabase.from('tactique_modele_sm').delete().eq('id', id).execute();
  }
}
