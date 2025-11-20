import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/data/data_export.dart';

class TactiqueUserSmRemoteDataSource {
  final SupabaseClient supabase;

  TactiqueUserSmRemoteDataSource(this.supabase);

  Future<List<TactiqueUserSmModel>> fetchAll(int saveId) async {
    final response = await supabase
        .from('tactique_user_sm')
        .select()
        .eq('save_id', saveId)
        .execute();
    final data = response.data as List<dynamic>;
    return data.map((e) => TactiqueUserSmModel.fromMap(e)).toList();
  }

  Future<TactiqueUserSmModel?> fetchLatest(int saveId) async {
    final response = await supabase
        .from('tactique_user_sm')
        .select()
        .eq('save_id', saveId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (response == null) return null;
    return TactiqueUserSmModel.fromMap(response);
  }

  Future<int> insert(TactiqueUserSmModel tactique) async {
    final toInsert = tactique.toMap()..remove('id');
    final row = await supabase.from('tactique_user_sm').insert(toInsert).select().single();
    return row['id'] as int;
  }

  Future<void> update(TactiqueUserSmModel tactique) async {
    final data = tactique.toMap()..remove('id');
    await supabase.from('tactique_user_sm').update(data).eq('id', tactique.id).execute();
  }

  Future<void> delete(int id) async {
    await supabase.from('tactique_user_sm').delete().eq('id', id).execute();
  }
}


