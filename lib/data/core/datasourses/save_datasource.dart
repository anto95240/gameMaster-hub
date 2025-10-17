// lib/data/core/datasources/save_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/save_model.dart';

class SaveDatasource {
  final SupabaseClient supabase;

  SaveDatasource(this.supabase);

  Future<List<SaveModel>> getSavesByGame(String gameId) async {
    final userId = supabase.auth.currentUser?.id;
    final response = await supabase
        .from('save')
        .select()
        .eq('game_id', gameId)
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => SaveModel.fromMap(e)).toList();
  }

  Future<SaveModel?> getSaveById(int saveId) async {
    final userId = supabase.auth.currentUser?.id;
    final response = await supabase
        .from('save')
        .select()
        .eq('id', saveId)
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return SaveModel.fromMap(response);
  }

  Future<int> createSave(SaveModel save) async {
    final data = save.toMap();
    final response = await supabase.from('save').insert(data).select().single();
    return response['id'] as int;
  }

  Future<void> updateSave(SaveModel save) async {
    final data = save.toMap();
    await supabase.from('save').update(data).eq('id', save.id);
  }

  Future<void> deleteSave(int saveId) async {
    // Supprimer tous les joueurs liés
    await supabase.from('players').delete().eq('save_id', saveId);
    await supabase.from('save').delete().eq('id', saveId);
  }

  Future<int> countPlayersBySave(int saveId) async {
    final response = await supabase
        .from('players')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('save_id', saveId);
    return response.count ?? 0;
  }

  Future<double> averageRatingBySave(int saveId) async {
    final response = await supabase
        .from('players')
        .select('rating');
    final players = response as List<dynamic>;
    if (players.isEmpty) return 0;
    final sum = players.fold<double>(0, (prev, element) => prev + (element['rating'] ?? 0));
    return sum / players.length;
  }
}
