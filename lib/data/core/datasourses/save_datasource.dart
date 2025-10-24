import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/data/data_export.dart';

class SaveDatasource {
  final SupabaseClient supabase;

  SaveDatasource(this.supabase);

  Future<List<SaveModel>> getSavesByGame(int gameId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('save')
        .select()
        .eq('game_id', gameId)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => SaveModel.fromMap(e)).toList();
  }

  Future<SaveModel?> getSaveById(int saveId) async {
    final response = await supabase
        .from('save')
        .select()
        .eq('id', saveId)
        .maybeSingle();

    if (response == null) return null;
    return SaveModel.fromMap(response);
  }

  Future<int> createSave(SaveModel save) async {
    final data = save.toMap()..remove('id');
    final response = await supabase.from('save').insert(data).select().single();
    return response['id'] as int;
  }

  Future<void> updateSave(SaveModel save) async {
    final data = save.toMap()..remove('id');
    await supabase.from('save').update(data).eq('id', save.id);
  }

  Future<void> deleteSave(int saveId) async {
    await supabase.from('joueur_sm').delete().eq('save_id', saveId);
    await supabase.from('save').delete().eq('id', saveId);
  }

  Future<int> countPlayersBySave(int saveId) async {
    final response = await supabase
        .from('joueur_sm')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('save_id', saveId);

    if (response.count == null) return 0;
    return response.count!;
  }

  Future<double> averageRatingBySave(int saveId) async {
    final response = await supabase
        .from('joueur_sm')
        .select('rating')
        .eq('save_id', saveId);

    if (response.isEmpty) return 0;
    final notes = response.map((r) => (r['note'] ?? 0).toDouble()).toList();
    final avg = notes.reduce((a, b) => a + b) / notes.length;
    return avg.isNaN ? 0 : avg;
  }
}
